-- ============================== Source file: RiskAnalytics_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactRiskAnalytics]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactRiskAnalytics';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'RiskAnalytics_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.FactRiskAnalytics ----
        IF OBJECT_ID(N'ims.FactRiskAnalytics', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactRiskAnalytics does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactRiskAnalytics;

        SET @SQL = N'INSERT INTO ims.FactRiskAnalytics (
            AnalyticsKey,
            SecurityKey,
            LinkAssetClassKey,
            LinkSecurityTypeKey,
            CurrencyKey,
            CountryKey,
            SourceSystemKey,
            DateKey,
            EffectiveDt,
            EquityVolatility,
            PERatio,
            KeyRateDur6M,
            KeyRateDur1Yr,
            KeyRateDur2y,
            KeyRateDur3y,
            KeyRateDur5y,
            KeyRateDur7y,
            KeyRateDur10y,
            Factor,
            WAC,
            WAM,
            ModifiedDur,
            SpreadDur,
            OAS,
            Convexity,
            AdjustedDur,
            YTM,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.AnalyticsKey,
            s.SecurityKey,
            s.LinkAssetClassKey,
            s.LinkSecurityTypeKey,
            s.CurrencyKey,
            s.CountryKey,
            s.SourceSystemKey,
            s.DateKey,
            s.EffectiveDt,
            s.EquityVolatility,
            s.PERatio,
            s.KeyRateDur6M,
            s.KeyRateDur1Yr,
            s.KeyRateDur2y,
            s.KeyRateDur3y,
            s.KeyRateDur5y,
            s.KeyRateDur7y,
            s.KeyRateDur10y,
            s.Factor,
            s.WAC,
            s.WAM,
            s.ModifiedDur,
            s.SpreadDur,
            s.OAS,
            s.Convexity,
            s.AdjustedDur,
            s.YTM,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.dbo.RiskAnalytics s
        LEFT JOIN ims.FactRiskAnalytics d
            ON s.AnalyticsKey = d.AnalyticsKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.FactRiskAnalyticsExt ----
        IF OBJECT_ID(N'ims.FactRiskAnalyticsExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactRiskAnalyticsExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactRiskAnalyticsExt;

        SET @SQL = N'INSERT INTO ims.FactRiskAnalyticsExt (
            AnalyticsKey
        )
        SELECT
            s.AnalyticsKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].RiskAnalyticsExt s
        LEFT JOIN ims.FactRiskAnalyticsExt d ON s.AnalyticsKey = d.AnalyticsKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in RiskAnalytics_Gold_Process';
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