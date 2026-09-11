-- ============================== Source file: sp_DollarAnalytics_FindMissingDates.sql ==============================
CREATE   PROCEDURE [ims].[sp_DollarAnalytics_FindMissingDates]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver',
    @BatchId INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'DollarAnalytics';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256) = 'DollarAnalytics_FindMissingDates';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @SQL NVARCHAR(MAX);

    BEGIN TRY

        SET @StartDate =
            ISNULL(
                @StartDate,
                DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
            );

        SET @EndDate =
            ISNULL(
                @EndDate,
                CAST(GETDATE() AS DATE)
            );

        SET @SQL = N'
        SELECT DISTINCT
            CAST(d.[Date] AS DATE) AS dt
        FROM dbo.[Date] d
        LEFT JOIN [' + @SilverLakehouse + N'].[dbo].[DollarAnalytics] fda
            ON fda.[EffectiveDt] = d.[Date]
        WHERE d.[Date] BETWEEN @StartDate AND @EndDate
          AND DATEPART(WEEKDAY, d.[Date]) BETWEEN 2 AND 6
          AND fda.[EffectiveDt] IS NULL
        ORDER BY dt;';

        EXEC sp_executesql
            @SQL,
            N'@StartDate DATE,@EndDate DATE',
            @StartDate,
            @EndDate;

        -----------------------------------------------------------------------
        -- Success Logging
        -----------------------------------------------------------------------
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
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
            ERROR_MESSAGE();

        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
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