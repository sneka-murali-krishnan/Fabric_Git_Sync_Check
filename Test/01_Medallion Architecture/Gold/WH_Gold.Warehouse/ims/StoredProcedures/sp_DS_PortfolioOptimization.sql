-- ============================== Source file: sp_DS_PortfolioOptimization.sql ==============================
CREATE   PROCEDURE [ims].[sp_DS_PortfolioOptimization]
    @BatchId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200);
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @StartTime DATETIME2(6);
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT;

    BEGIN TRY

        -----------------------------------------------------------------------
        -- TABLE 1 : DS_PortfolioOptimization_Weights
        -----------------------------------------------------------------------
        SET @TableName = 'DS_PortfolioOptimization_Weights';
        SET @StartTime = SYSUTCDATETIME();

        IF OBJECT_ID(N'ims.DS_PortfolioOptimization_Weights', N'U') IS NULL
        BEGIN
            THROW 50000,
                'Invalid operation. Table ims.DS_PortfolioOptimization_Weights does not exist.',
                1;
        END;

        TRUNCATE TABLE ims.DS_PortfolioOptimization_Weights;

        INSERT INTO ims.DS_PortfolioOptimization_Weights
        (
            RowId,
            PortfolioId,
            Ticker,
            AsOfDate,
            CurrentWeight,
            TargetWeight,
            WeightDelta,
            TradeAction,
            TradeSizeValue,
            CreatedDate,
            UpdatedDate
        )
        SELECT
            RowId,
            PortfolioId,
            Ticker,
            AsOfDate,
            CurrentWeight,
            TargetWeight,
            WeightDelta,
            TradeAction,
            TradeSizeValue,
            CreatedDate,
            UpdatedDate
        FROM staging.DS_PortfolioOptimization_Weights;

        SET @RowsInserted = @@ROWCOUNT;
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
                'sp_DS_PortfolioOptimization'
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- TABLE 2 : DS_PortfolioOptimization_Performance
        -----------------------------------------------------------------------
        SET @TableName = 'DS_PortfolioOptimization_Performance';
        SET @StartTime = SYSUTCDATETIME();

        IF OBJECT_ID(N'ims.DS_PortfolioOptimization_Performance', N'U') IS NULL
        BEGIN
            THROW 50000,
                'Invalid operation. Table ims.DS_PortfolioOptimization_Performance does not exist.',
                1; -- Fixed missing state value and statement terminator
        END;

        TRUNCATE TABLE ims.DS_PortfolioOptimization_Performance;

        INSERT INTO ims.DS_PortfolioOptimization_Performance
        (
            RowId,
            PortfolioId,
            PeriodStart,
            PeriodEnd,
            NetReturn,
            Sharpe,
            MaxDrawdown,
            Turnover,
            CreatedDate,
            UpdatedDate
        )
        SELECT
            RowId,
            PortfolioId,
            PeriodStart,
            PeriodEnd,
            NetReturn,
            Sharpe,
            MaxDrawdown,
            Turnover,
            CreatedDate,
            UpdatedDate
        FROM staging.DS_PortfolioOptimization_Performance;

        SET @RowsInserted = @@ROWCOUNT;
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
                'sp_DS_PortfolioOptimization'
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- TABLE 3 : DS_PortfolioOptimization_RiskRegime
        -----------------------------------------------------------------------
        SET @TableName = 'DS_PortfolioOptimization_RiskRegime';
        SET @StartTime = SYSUTCDATETIME();

        IF OBJECT_ID(N'ims.DS_PortfolioOptimization_RiskRegime', N'U') IS NULL
        BEGIN
            THROW 50000,
                'Invalid operation. Table ims.DS_PortfolioOptimization_RiskRegime does not exist.',
                1;
        END;

        TRUNCATE TABLE ims.DS_PortfolioOptimization_RiskRegime;

        INSERT INTO ims.DS_PortfolioOptimization_RiskRegime
        (
            RowId,
            PortfolioId,
            EffectiveDate,
            GARCH_Volatility,
            VolatilityRegime,
            PPO_AAPL,
            PPO_MSFT,
            CreatedDate,
            UpdatedDate
        )
        SELECT
            RowId,
            PortfolioId,
            EffectiveDate,
            GARCH_Volatility,
            VolatilityRegime,
            PPO_AAPL,
            PPO_MSFT,
            CreatedDate,
            UpdatedDate
        FROM staging.DS_PortfolioOptimization_RiskRegime;

        SET @RowsInserted = @@ROWCOUNT;
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
                'sp_DS_PortfolioOptimization'
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
            CAST(DATEDIFF(SECOND, ISNULL(@StartTime, @EndTime), @EndTime) AS VARCHAR(20))
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
                'sp_DS_PortfolioOptimization'
            );

        END TRY
        BEGIN CATCH
            -- Swallow logging errors
        END CATCH;

        THROW;

    END CATCH

END;

GO