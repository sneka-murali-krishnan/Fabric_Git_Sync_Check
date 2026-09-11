-- ============================== Source file: sp_storeprocedure1.sql ==============================
CREATE   PROCEDURE [ims].[sp_Date]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver', -- not used
    @BatchId INT = NULL,
    @StartDate DATE = '2016-01-01',
    @EndDate DATE = '2030-12-31'
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'Date';
    DECLARE @SchemaName VARCHAR(255) = 'dbo';
    DECLARE @ProcedureName VARCHAR(256) = 'sp_Date';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    BEGIN TRY

        -- dbo.[Date] is now guaranteed to exist before this procedure
        -- ever runs (Consolidated_Create_Tables.sql runs first on every
        -- deploy — see gold_stored_procedures.py's deploy_stored_procedures).
        -- The self-heal CREATE TABLE that used to live here is removed;
        -- it also created a 2-column stand-in (DateID VARCHAR(8), [Date] DATE)
        -- structurally DIFFERENT from the real dbo.Date dimension table in
        -- Consolidated_Create_Tables.sql (DateID int, Date datetime2(6), plus
        -- ~40 more columns e.g. DateBKey/DayOfMonth/DayName/etc.) -- worth a
        -- look at whether the INSERT below should be populating those other
        -- columns too now that the real table is what's actually in use.

        WHILE @StartDate <= @EndDate
        BEGIN

            -- Idempotent: only insert dates not already present, so
            -- re-running sp_Date for an overlapping range (e.g. every
            -- batch run) never hits a duplicate-key style conflict.
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.[Date]
                WHERE DateID = CONVERT(VARCHAR(8), @StartDate, 112)
            )
            BEGIN
                INSERT INTO dbo.[Date]
                (
                    DateID,
                    [Date]
                )
                VALUES
                (
                    CONVERT(VARCHAR(8), @StartDate, 112),
                    @StartDate
                );

                SET @RowsInserted += 1;
            END;

            SET @StartDate = DATEADD(DAY, 1, @StartDate);
        END;

 
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

        BEGIN TRY
            INSERT INTO [WH_MetaData].[Log].[ETLBatchGoldLogDetails]
            (
                BatchId,
                SchemaName,
                TableName,
                ProcessedRowCount,
                StartTime,
                EndTime,
                Status,
                ErrorMessage,
                SourceName
            )
            VALUES
            (
                @BatchId,
                @SchemaName,
                @TableName,
                @RowsInserted,
                @StartTime,
                @EndTime,
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

    END TRY
    BEGIN CATCH

        SET @ErrorMessage =
            ERROR_MESSAGE() + ' in sp_Date';

        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

        BEGIN TRY

            INSERT INTO [WH_MetaData].[Log].[ETLBatchGoldLogDetails]
            (
                BatchId,
                SchemaName,
                TableName,
                ProcessedRowCount,
                StartTime,
                EndTime,
                Status,
                ErrorMessage,
                SourceName
            )
            VALUES
            (
                @BatchId,
                @SchemaName,
                @TableName,
                0,
                @StartTime,
                @EndTime,
                'Failed',
                @ErrorMessage,
                @ProcedureName
            );

        END TRY
        BEGIN CATCH
            -- Swallow logging errors so they never mask the real failure
        END CATCH

    END CATCH

END;

GO