-- ============================== Source file: sp_IndexSecurity_New_Data_Generation.sql ==============================
CREATE   PROCEDURE [ims].[sp_IndexSecurity_New_Data_Generation]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver',
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'IndexSecurityRaw';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256) = 'IndexSecurity_New_Data_Generation';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    DECLARE @MaxDate DATETIME2(6);
    DECLARE @SQL NVARCHAR(MAX);

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Validate target table
        -----------------------------------------------------------------------
        IF OBJECT_ID(N'dbo.IndexSecurityRaw', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table dbo.IndexSecurityRaw does not exist.', 1;
        END;

        -----------------------------------------------------------------------
        -- Get latest AsOfDate from Silver Lakehouse
        -----------------------------------------------------------------------
        SET @SQL = N'
            SELECT @MaxDateOUT = MAX(AsOfDate)
            FROM [' + @SilverLakehouse + N'].[dbo].[IndexSecurity];
        ';

        EXEC sp_executesql
            @SQL,
            N'@MaxDateOUT DATETIME2(6) OUTPUT',
            @MaxDateOUT = @MaxDate OUTPUT;

        IF @MaxDate IS NULL
        BEGIN
            THROW 50001, 'No records found in source table IndexSecurity.', 1;
        END;

        -----------------------------------------------------------------------
        -- Full Refresh
        -----------------------------------------------------------------------
        TRUNCATE TABLE dbo.IndexSecurityRaw;

        SET @SQL = N'
            INSERT INTO dbo.IndexSecurityRaw
            (
                AsOfDate,
                BenchmarkCode,
                Identifier,
                CurrentFace
            )
            SELECT
                FORMAT(
                    SYSDATETIMEOFFSET() AT TIME ZONE ''Pacific Standard Time'',
                    ''MM/dd/yyyy''
                ) AS AsOfDate,
                BenchmarkCode,
                Identifier,
                CurrentFace
            FROM [' + @SilverLakehouse + N'].[dbo].[IndexSecurity]
            WHERE AsOfDate = @MaxDate;
        ';

        EXEC sp_executesql
            @SQL,
            N'@MaxDate DATETIME2(6)',
            @MaxDate = @MaxDate;

        SET @RowsInserted = @@ROWCOUNT;

        IF @RowsInserted = 0
        BEGIN
            THROW 50001, 'No records were inserted into IndexSecurityRaw.', 1;
        END;

        -----------------------------------------------------------------------
        -- Success Logging
        -----------------------------------------------------------------------
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
            ERROR_MESSAGE() + ' in IndexSecurity_New_Data_Generation';

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