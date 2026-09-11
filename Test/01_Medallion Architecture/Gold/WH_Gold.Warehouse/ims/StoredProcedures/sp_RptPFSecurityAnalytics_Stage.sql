-- ============================== Source file: sp_RptPFSecurityAnalytics_Stage.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptPFSecurityAnalytics_Stage]
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptPFBMSecurityAnalytics_Stage';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Full Refresh
        -----------------------------------------------------------------------
        TRUNCATE TABLE [ims].[RptPFBMSecurityAnalytics_Stage];

        INSERT INTO [ims].[RptPFBMSecurityAnalytics_Stage]
        (
            SecurityAnalyticsKey,
            SecurityKey,
            LinkAssetClassKey,
            LinkSecurityTypeKey,
            CurrencyKey,
            CountryKey,
            ShortName,
            LongName,
            SecurityDescription,
            SourceSystemKey,
            IndustryGICS,
            SubindustryGICS,
            SectorGICS,
            IndustryGroupGICS,
            SubSectorGICS,
            ProductType,
            Coupon,
            EffectiveDt,
            PriceStartDay,
            PriceLastEOD,
            DividendYield,
            DividendAmount,
            NextDividendPaydate,
            LastDividendPaydate,
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
            KeyRateDur6M,
            KeyRateDur1Yr,
            KeyRateDur2y,
            KeyRateDur3y,
            KeyRateDur5y,
            KeyRateDur7y,
            KeyRateDur10y,
            WAC,
            WAM,
            ModifiedDur,
            SpreadDur,
            OAS,
            Convexity,
            AdjustedDur,
            YTM,
            FIGI,
            SYMBOL,
            CUSIP,
            ISIN,
            SEDOL,
            PE,
            Beta,
            Identifier,
            Delta,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            ROW_NUMBER() OVER
            (
                ORDER BY SecurityKey, EffectiveDt, SYMBOL
            ) AS SecurityAnalyticsKey,
            *
        FROM
        (
            SELECT DISTINCT
                s.SecurityKey,
                s.LinkAssetClassKey,
                s.LinkSecurityTypeKey,
                s.CurrencyKey,
                s.CountryKey,
                s.ShortName,
                s.LongName,
                s.SecurityDescription,
                s.SourceSystemKey,
                s.IndustryGICS,
                s.SubindustryGICS,
                s.SectorGICS,
                s.IndustryGroupGICS,
                s.SubSectorGICS,
                s.ProductType,
                s.Coupon,
                sda.EffectiveDt,
                sda.PriceStartDay,
                sda.PriceLastEOD,
                sda.DividendYield,
                sda.DividendAmount,
                sda.NextDividendPaydate,
                sda.LastDividendPaydate,
                sda.FiftyTwoWeekHigh,
                sda.FiftyTwoWeekLow,
                sda.CurrentYearHigh,
                sda.CurrentYearLow,
                sda.MarketPrice,
                sda.Factor,
                sda.OneMCPR,
                sda.ThreeMCPR,
                sda.SixMCPR,
                sda.TwelveMCPR,
                sda.DTC,
                sra.KeyRateDur6M,
                sra.KeyRateDur1Yr,
                sra.KeyRateDur2y,
                sra.KeyRateDur3y,
                sra.KeyRateDur5y,
                sra.KeyRateDur7y,
                sra.KeyRateDur10y,
                sra.WAC,
                sra.WAM,
                sra.ModifiedDur,
                sra.SpreadDur,
                sra.OAS,
                sra.Convexity,
                sra.AdjustedDur,
                sra.YTM,
                si.FIGI,
                si.SYMBOL,
                si.CUSIP,
                si.ISIN,
                si.SEDOL,
                sra.PERatio AS PE,
                sra.EquityVolatility AS Beta,
                CASE
                    WHEN si.CUSIP <> '' THEN si.CUSIP
                    ELSE si.SYMBOL
                END AS Identifier,
                sda.MarketPrice - sda.PriceStartDay AS Delta,
                s.CreatedBy,
                s.CreatedDate,
                s.UpdatedBy,
                CASE
                    WHEN s.UpdatedDate > sda.UpdatedDate
                         AND s.UpdatedDate > sra.UpdatedDate
                         AND s.UpdatedDate > sid.UpdatedDate
                        THEN s.UpdatedDate
                    WHEN sda.UpdatedDate > s.UpdatedDate
                         AND sda.UpdatedDate > sra.UpdatedDate
                         AND sda.UpdatedDate > sid.UpdatedDate
                        THEN sda.UpdatedDate
                    WHEN sra.UpdatedDate > s.UpdatedDate
                         AND sra.UpdatedDate > sda.UpdatedDate
                         AND sra.UpdatedDate > sid.UpdatedDate
                        THEN sra.UpdatedDate
                    ELSE sid.UpdatedDate
                END AS UpdatedDate
            FROM [ims].[DimSecurity] s
            LEFT JOIN [ims].[FactDollarAnalytics] sda
                ON sda.SecurityKey = s.SecurityKey
            LEFT JOIN [ims].[FactRiskAnalytics] sra
                ON sra.SecurityKey = s.SecurityKey
               AND sra.EffectiveDt = sda.EffectiveDt
            LEFT JOIN [ims].[DimSecurityIdentifier] sid
                ON sid.SecurityKey = s.SecurityKey
            JOIN
            (
                SELECT
                    SecurityKey,
                    FIGI,
                    SYMBOL,
                    CUSIP,
                    ISIN,
                    SEDOL
                FROM
                (
                    SELECT
                        SecurityKey,
                        Identifier,
                        IdentifierType
                    FROM [ims].[DimSecurityIdentifier]
                ) si
                PIVOT
                (
                    MIN(Identifier)
                    FOR IdentifierType IN
                    (
                        FIGI,
                        SYMBOL,
                        CUSIP,
                        ISIN,
                        SEDOL
                    )
                ) p
            ) si
                ON si.SecurityKey = s.SecurityKey
        ) Final;

        SET @RowsInserted = @@ROWCOUNT;

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
                'sp_RptPFSecurityAnalytics_Stage'
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
            'sp_RptPFSecurityAnalytics_Stage'
        );

        THROW;

    END CATCH

END;

GO