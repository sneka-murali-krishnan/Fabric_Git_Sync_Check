-- ============================== Source file: sp_RptPortfolioPeerComparison.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptPortfolioPeerComparison]
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptPortfolioPeerComparison';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Cleanup
        -----------------------------------------------------------------------

        IF OBJECT_ID('ims.PortfolioPeerCTE', 'U') IS NOT NULL
            DROP TABLE ims.PortfolioPeerCTE;

        IF OBJECT_ID('ims.PortfolioPeerCalendarCTE', 'U') IS NOT NULL
            DROP TABLE ims.PortfolioPeerCalendarCTE;

        IF OBJECT_ID('ims.PortfolioPeerFinalCTE', 'U') IS NOT NULL
            DROP TABLE ims.PortfolioPeerFinalCTE;

        -----------------------------------------------------------------------
        -- Build Peer Data
        -----------------------------------------------------------------------

        SELECT DISTINCT
            dpp.PortfolioCode,
            dpp.PFBMCode AS Ticker,
            CASE
                WHEN dpp.PFBMType = 'Portfolio' THEN dp.ShortName
                WHEN dpp.PFBMType = 'Benchmark' THEN db.BenchmarkName
            END AS FundName,
            rpad.AsOfDate,
            (
                SELECT SUM(HoldingsMarketValue)
                FROM ims.RptPosAnalyticsData
                WHERE PFBMCode = rpad.PFBMCode
                  AND AsOfDate = rpad.AsOfDate
            ) AS NetAssetValue
        INTO ims.PortfolioPeerCTE
        FROM ims.DimPortfolioPeer dpp
        LEFT JOIN ims.DimPortfolio dp
            ON dp.PortfolioCode = dpp.PFBMCode
        LEFT JOIN ims.DimBenchmark db
            ON db.BenchmarkCode = dpp.PFBMCode
        INNER JOIN ims.RptPosAnalyticsData rpad
            ON rpad.PFBMCode = dpp.PFBMCode;

        DECLARE @StartDate DATE;
        DECLARE @EndDate DATE;
        DECLARE @CurrentDate DATE;

        SET @StartDate = (SELECT MIN(AsOfDate) FROM ims.PortfolioPeerCTE);
        SET @EndDate   = (SELECT MAX(AsOfDate) FROM ims.PortfolioPeerCTE);
        SET @CurrentDate = @StartDate;

        CREATE TABLE ims.PortfolioPeerCalendarCTE
        (
            CalendarDate DATE
        );

        WHILE @CurrentDate <= @EndDate
        BEGIN
            INSERT INTO ims.PortfolioPeerCalendarCTE
            (
                CalendarDate
            )
            VALUES
            (
                @CurrentDate
            );

            SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
        END;

        WITH UniqueCodesCTE AS
        (
            SELECT DISTINCT
                PortfolioCode,
                Ticker
            FROM ims.PortfolioPeerCTE
        ),
        ExpandedDatesCTE AS
        (
            SELECT
                uc.PortfolioCode,
                uc.Ticker,
                ppc.CalendarDate AS AsOfDate
            FROM ims.PortfolioPeerCalendarCTE ppc
            CROSS JOIN UniqueCodesCTE uc
        ),
        FilledDataCTE AS
        (
            SELECT
                ed.PortfolioCode,
                ed.Ticker,
                ppc.FundName,
                ed.AsOfDate,
                ppc.NetAssetValue
            FROM ExpandedDatesCTE ed
            LEFT JOIN ims.PortfolioPeerCTE ppc
                ON ed.PortfolioCode = ppc.PortfolioCode
               AND ed.Ticker = ppc.Ticker
               AND ed.AsOfDate = ppc.AsOfDate
        ),
        PopulatedResultCTE AS
        (
            SELECT
                fd.PortfolioCode,
                fd.Ticker,
                fd.FundName,
                fd.AsOfDate,
                COALESCE
                (
                    fd.NetAssetValue,
                    (
                        SELECT TOP 1 pp.NetAssetValue
                        FROM ims.PortfolioPeerCTE pp
                        WHERE pp.PortfolioCode = fd.PortfolioCode
                          AND pp.Ticker = fd.Ticker
                          AND pp.AsOfDate < fd.AsOfDate
                        ORDER BY pp.AsOfDate DESC
                    )
                ) AS NetAssetValue
            FROM FilledDataCTE fd
        ),
        FinalResultCTE AS
        (
            SELECT
                c.PortfolioCode,
                c.Ticker,
                c.FundName,
                c.AsOfDate,
                c.NetAssetValue,
                c.NetAssetValue - p1d.NetAssetValue AS Return1D,
                c.NetAssetValue - p1w.NetAssetValue AS Return1W,
                c.NetAssetValue - p1m.NetAssetValue AS Return1M,
                c.NetAssetValue - p3m.NetAssetValue AS Return3M,
                c.NetAssetValue - p1y.NetAssetValue AS Return1Y,
                c.NetAssetValue - p3y.NetAssetValue AS Return3Y,
                c.NetAssetValue - p5y.NetAssetValue AS Return5Y
            FROM PopulatedResultCTE c
            LEFT JOIN PopulatedResultCTE p1d
                ON p1d.PortfolioCode = c.PortfolioCode
               AND p1d.Ticker = c.Ticker
               AND p1d.AsOfDate = DATEADD(DAY, -1, c.AsOfDate)
            LEFT JOIN PopulatedResultCTE p1w
                ON p1w.PortfolioCode = c.PortfolioCode
               AND p1w.Ticker = c.Ticker
               AND p1w.AsOfDate = DATEADD(DAY, -7, c.AsOfDate)
            LEFT JOIN PopulatedResultCTE p1m
                ON p1m.PortfolioCode = c.PortfolioCode
               AND p1m.Ticker = c.Ticker
               AND p1m.AsOfDate = DATEADD(MONTH, -1, c.AsOfDate)
            LEFT JOIN PopulatedResultCTE p3m
                ON p3m.PortfolioCode = c.PortfolioCode
               AND p3m.Ticker = c.Ticker
               AND p3m.AsOfDate = DATEADD(MONTH, -3, c.AsOfDate)
            LEFT JOIN PopulatedResultCTE p1y
                ON p1y.PortfolioCode = c.PortfolioCode
               AND p1y.Ticker = c.Ticker
               AND p1y.AsOfDate = DATEADD(YEAR, -1, c.AsOfDate)
            LEFT JOIN PopulatedResultCTE p3y
                ON p3y.PortfolioCode = c.PortfolioCode
               AND p3y.Ticker = c.Ticker
               AND p3y.AsOfDate = DATEADD(YEAR, -3, c.AsOfDate)
            LEFT JOIN PopulatedResultCTE p5y
                ON p5y.PortfolioCode = c.PortfolioCode
               AND p5y.Ticker = c.Ticker
               AND p5y.AsOfDate = DATEADD(YEAR, -5, c.AsOfDate)
        )
        SELECT *
        INTO ims.PortfolioPeerFinalCTE
        FROM FinalResultCTE;

        -----------------------------------------------------------------------
        -- Refresh Target Table
        -----------------------------------------------------------------------

        TRUNCATE TABLE ims.RptPortfolioPeerComparison;

        INSERT INTO ims.RptPortfolioPeerComparison
        SELECT *
        FROM ims.PortfolioPeerFinalCTE;

        SET @RowsInserted = @@ROWCOUNT;

        -----------------------------------------------------------------------
        -- Cleanup Temp Tables
        -----------------------------------------------------------------------

        DROP TABLE ims.PortfolioPeerCTE;
        DROP TABLE ims.PortfolioPeerCalendarCTE;
        DROP TABLE ims.PortfolioPeerFinalCTE;

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
                'sp_RptPortfolioPeerComparison'
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

    END TRY
    BEGIN CATCH

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

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
            'sp_RptPortfolioPeerComparison'
        );

        IF OBJECT_ID('ims.PortfolioPeerCTE', 'U') IS NOT NULL
            DROP TABLE ims.PortfolioPeerCTE;

        IF OBJECT_ID('ims.PortfolioPeerCalendarCTE', 'U') IS NOT NULL
            DROP TABLE ims.PortfolioPeerCalendarCTE;

        IF OBJECT_ID('ims.PortfolioPeerFinalCTE', 'U') IS NOT NULL
            DROP TABLE ims.PortfolioPeerFinalCTE;

        THROW;

    END CATCH

END;

GO