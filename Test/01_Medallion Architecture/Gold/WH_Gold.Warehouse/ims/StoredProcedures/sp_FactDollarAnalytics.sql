-- ============================== Source file: FactDollarAnalytics_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactDollarAnalytics]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactDollarAnalytics';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'FactDollarAnalytics_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.FactDollarAnalytics ----
        IF OBJECT_ID(N'ims.FactDollarAnalytics', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactDollarAnalytics does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactDollarAnalytics;

        SET @SQL = N'INSERT INTO ims.FactDollarAnalytics (
            AnalyticsKey,
            SecurityKey,
            CustomAssetClassKey,
            CustomSecurityTypeKey,
            CurrencyKey,
            CountryKey,
            SourceSystemKey,
            DateKey,
            EffectiveDt,
            NextDividendPaydate,
            LastDividendPaydate,
            PriceStartDay,
            PriceLastEOD,
            DividendYield,
            DividendAmount,
            FiftyTwoWeekHigh,
            FiftyTwoWeekLow,
            CurrentYearHigh,
            CurrentYearLow,
            MarketPrice,
            Factor,
            OneMCPR,
            ThreeMCPR,
            SixMCPR,
            TwelveMCPR,
            DTC,
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
            s.NextDividendPaydate,
            s.LastDividendPaydate,
            s.PriceStartDay,
            s.PriceLastEOD,
            s.DividendYield,
            s.DividendAmount,
            s.FiftyTwoWeekHigh,
            s.FiftyTwoWeekLow,
            s.CurrentYearHigh,
            s.CurrentYearLow,
            s.MarketPrice,
            s.Factor,
            s.OneMCPR,
            s.ThreeMCPR,
            s.SixMCPR,
            s.TwelveMCPR,
            s.DTC,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.dbo.DollarAnalytics s
        Left JOIN ims.FactDollarAnalytics d
            ON s.AnalyticsKey = d.AnalyticsKey
        WHERE s.CreatedDate > ''2024-12-03 00:00:00'' OR s.UpdatedDate > ''2024-12-03 00:00:00'';';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.FactDollarAnalyticsExt ----
        IF OBJECT_ID(N'ims.FactDollarAnalyticsExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactDollarAnalyticsExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactDollarAnalyticsExt;

        SET @SQL = N'INSERT INTO ims.FactDollarAnalyticsExt (
            AnalyticsKey
        )
        SELECT
            s.AnalyticsKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].DollarAnalyticsExt s
        LEFT JOIN ims.FactDollarAnalyticsExt d ON s.AnalyticsKey = d.AnalyticsKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in FactDollarAnalytics_Gold_Process';
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