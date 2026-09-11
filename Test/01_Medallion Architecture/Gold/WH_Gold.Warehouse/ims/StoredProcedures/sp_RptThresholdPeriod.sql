-- ============================== Source file: sp_RptThresholdPeriod.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptThresholdPeriod]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver',
    @BatchId INT = NULL,
    @StartDate DATE = '2020-01-01',
    @EndDate DATE = NULL,
    @BenchmarkCode VARCHAR(255) = 'GSPC',
    @PortfolioCode VARCHAR(255) = 'GOS100',
    @Threshold FLOAT = 0.05
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptThresholdPeriod';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256) = 'sp_RptThresholdPeriod';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    BEGIN TRY

        IF @EndDate IS NULL
        BEGIN
            SET @EndDate = CAST(DATEADD(DAY, -DAY(GETDATE()), GETDATE()) AS DATE);
        END;

        DROP TABLE IF EXISTS ims.TmpJoinTbl;
        DROP TABLE IF EXISTS ims.TmpThresholdTbl;
        DROP TABLE IF EXISTS ims.TmpThresholdPeriodTbl;

        -----------------------------------------------------------------------
        -- Existing Business Logic
        -----------------------------------------------------------------------

        /* Keep all your existing CTEs and calculations exactly as-is:
             benchmarkTbl
             portfolioTbl
             benchmarkFuture6MonthsTbl
             portfolioFuture6MonthsTbl
             joinTbl
             TmpJoinTbl
             TmpThresholdTbl
             WHILE loop
             periodTbl
             thresholdJoinTbl
             finalTbl
             TmpThresholdPeriodTbl
        */

        -----------------------------------------------------------------------
        -- Delete Existing Data
        -----------------------------------------------------------------------

        DELETE FROM [ims].[RptThresholdPeriod]
        WHERE
        (
            ([PFBMCode] = @BenchmarkCode AND [PFBMType] = 'Benchmark')
            OR
            ([PFBMCode] = @PortfolioCode AND [PFBMType] = 'Portfolio')
        )
        AND
        (
            ([MVStartDate] BETWEEN @StartDate AND @EndDate)
            OR
            ([MVEndDate] BETWEEN @StartDate AND @EndDate)
            OR
            ([MVStartDate] < @StartDate AND @EndDate < [MVEndDate])
        );

        -----------------------------------------------------------------------
        -- Insert New Data
        -----------------------------------------------------------------------

        INSERT INTO [ims].[RptThresholdPeriod]
        (
            MVPeriod,
            PFBMCode,
            PFBMType,
            MVDuration,
            MVStartDate,
            MVEndDate,
            MVDateRange,
            MVDateRangeFuture6Months,
            MVPercentageChange,
            MVPercentageChangeFuture6Months,
            BMIsRising
        )
        SELECT
            MVPeriod,
            PFBMCode,
            PFBMType,
            MVDuration,
            MVStartDate,
            MVEndDate,
            MVDateRange,
            MVDateRangeFuture6Months,
            MVPercentageChange,
            MVPercentageChangeFuture6Months,
            BMIsRising
        FROM ims.TmpThresholdPeriodTbl;

        SET @RowsInserted = @@ROWCOUNT;

        -----------------------------------------------------------------------
        -- Cleanup
        -----------------------------------------------------------------------

        DROP TABLE IF EXISTS ims.TmpJoinTbl;
        DROP TABLE IF EXISTS ims.TmpThresholdTbl;
        DROP TABLE IF EXISTS ims.TmpThresholdPeriodTbl;

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

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(
                DATEDIFF(
                    SECOND,
                    @StartTime,
                    @EndTime
                ) AS VARCHAR(20)
            ) + ' Seconds';

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
            -- Swallow logging errors
        END CATCH;

        DROP TABLE IF EXISTS ims.TmpJoinTbl;
        DROP TABLE IF EXISTS ims.TmpThresholdTbl;
        DROP TABLE IF EXISTS ims.TmpThresholdPeriodTbl;

    END CATCH

END;

GO