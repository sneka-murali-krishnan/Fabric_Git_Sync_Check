-- ============================== Source file: Transact_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactTransact]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactTransact';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'Transact_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.FactTransact ----
        IF OBJECT_ID(N'ims.FactTransact', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactTransact does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactTransact;

        SET @SQL = N'INSERT INTO ims.FactTransact (
            TransactKey,
            Identifier,
            ReportedDate,
            TradeDate,
            SettlementDate,
            CanceledDate,
            TradeType,
            BuyProtection,
            Quantity,
            PriceLocal,
            PriceBase,
            PriceUSD,
            CommissionLocal,
            CommissionBase,
            CommissionUSD,
            ImpliedCommissionLocal,
            ImpliedCommissionBase,
            ImpliedCommissionUSD,
            FeesLocal,
            FeesBase,
            FeesUSD,
            NetAmountLocal,
            NetAmountBase,
            NetAmountUSD,
            GrossAmountLocal,
            GrossAmountBase,
            GrossAmountUSD,
            CostLocal,
            CostBase,
            CostUSD,
            GainLossLocal,
            PercentGainLossLocal,
            PercentGainLossBase,
            PercentGainLossUSD,
            AccruedInterestLocal,
            AccruedInterestBase,
            AccruedInterestUSD,
            DateKey,
            SecurityKey,
            PortfolioKey,
            BrokerKey,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.TransactKey,
            s.Identifier,
            s.ReportedDate,
            s.TradeDate,
            s.SettlementDate,
            s.CanceledDate,
            s.TradeType,
            s.BuyProtection,
            s.Quantity,
            s.PriceLocal,
            s.PriceBase,
            s.PriceUSD,
            s.CommissionLocal,
            s.CommissionBase,
            s.CommissionUSD,
            s.ImpliedCommissionLocal,
            s.ImpliedCommissionBase,
            s.ImpliedCommissionUSD,
            s.FeesLocal,
            s.FeesBase,
            s.FeesUSD,
            s.NetAmountLocal,
            s.NetAmountBase,
            s.NetAmountUSD,
            s.GrossAmountLocal,
            s.GrossAmountBase,
            s.GrossAmountUSD,
            s.CostLocal,
            s.CostBase,
            s.CostUSD,
            s.GainLossLocal,
            s.PercentGainLossLocal,
            s.PercentGainLossBase,
            s.PercentGainLossUSD,
            s.AccruedInterestLocal,
            s.AccruedInterestBase,
            s.AccruedInterestUSD,
            CAST(CONVERT(VARCHAR(8), s.TradeDate, 112) AS INT), --da.DateKey,
            se.SecurityKey,
            p.PortfolioKey,
            b.BrokerKey,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Transact s
        LEFT JOIN ims.FactTransact d
            ON d.TransactKey = s.TransactKey
        LEFT JOIN dbo.DimDate da
            ON CAST(da.[Date] AS DATE) = CAST(d.TradeDate AS DATE)
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityIdentifier si
            ON si.Identifier = s.Identifier
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Security se
            ON se.SecurityKey = si.SecurityKey
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Portfolio p
            ON p.PortfolioKey = s.PortfolioKey
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Broker b
            ON b.BrokerKey = s.BrokerKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.FactTransactExt ----
        IF OBJECT_ID(N'ims.FactTransactExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactTransactExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactTransactExt;

        SET @SQL = N'INSERT INTO ims.FactTransactExt (
            TransactKey
        )
        SELECT
            s.TransactKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].TransactExt s
        LEFT JOIN ims.FactTransactExt d ON s.TransactKey = d.TransactKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' Seconds';

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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Transact_Gold_Process';
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' Seconds';

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
            -- swallow logging errors so they never mask the real failure
        END CATCH
    END CATCH
END

GO