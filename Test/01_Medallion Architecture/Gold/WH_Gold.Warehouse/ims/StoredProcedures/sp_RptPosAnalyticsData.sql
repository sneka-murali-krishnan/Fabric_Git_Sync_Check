-- ============================== Source file: sp_RptPosAnalyticsData.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptPosAnalyticsData]
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptPosAnalyticsData';
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
        TRUNCATE TABLE [ims].[RptPosAnalyticsData];

        INSERT INTO [ims].[RptPosAnalyticsData]
        (
            [PosAnalyticsDataKey],
            [SecurityKey],
            [LinkAssetClassKey],
            [AssetClassName],
            [LinkSecurityTypeKey],
            [CurrencyKey],
            [CountryKey],
            [ShortName],
            [LongName],
            [SecurityDescription],
            [SourceSystemKey],
            [IndustryGICS],
            [SubindustryGICS],
            [SectorGICS],
            [IndustryGroupGICS],
            [SubSectorGICS],
            [EffectiveDt],
            [PriceStartDay],
            [PriceLastEOD],
            [DividendYield],
            [DividendAmount],
            [NextDividendPaydate],
            [LastDividendPaydate],
            [FiftyTwoWeekHigh],
            [FiftyTwoWeekLow],
            [CurrentYearHigh],
            [CurrentYearLow],
            [MarketPrice],
            [Factor],
            [OneMCPR],
            [ThreeMCPR],
            [SixMCPR],
            [TwelveMCPR],
            [DTC],
            [KeyRateDur6M],
            [KeyRateDur1Yr],
            [KeyRateDur2y],
            [KeyRateDur3y],
            [KeyRateDur5y],
            [KeyRateDur7y],
            [KeyRateDur10y],
            [WAC],
            [WAM],
            [ModifiedDur],
            [SpreadDur],
            [OAS],
            [Convexity],
            [AdjustedDur],
            [YTM],
            [FIGI],
            [SYMBOL],
            [CUSIP],
            [ISIN],
            [SEDOL],
            [PE],
            [Beta],
            [Identifier],
            [ENV],
            [SOC],
            [GOV],
            [ESG],
            [Ratings],
            [PFBMCode],
            [PFBMSecurityKey],
            [AsOfDate],
            [Quantity],
            [IsPortfolio],
            [HoldingsMarketValue],
            [CreatedBy],
            [CreatedDate],
            [UpdatedBy],
            [UpdatedDate]
        )
        SELECT
            [PosAnalyticsDataKey],
            [SecurityKey],
            [LinkAssetClassKey],
            [AssetClassName],
            [LinkSecurityTypeKey],
            [CurrencyKey],
            [CountryKey],
            [ShortName],
            [LongName],
            [SecurityDescription],
            [SourceSystemKey],
            [IndustryGICS],
            [SubindustryGICS],
            [SectorGICS],
            [IndustryGroupGICS],
            [SubSectorGICS],
            [EffectiveDt],
            [PriceStartDay],
            [PriceLastEOD],
            [DividendYield],
            [DividendAmount],
            [NextDividendPaydate],
            [LastDividendPaydate],
            [FiftyTwoWeekHigh],
            [FiftyTwoWeekLow],
            [CurrentYearHigh],
            [CurrentYearLow],
            [MarketPrice],
            [Factor],
            [OneMCPR],
            [ThreeMCPR],
            [SixMCPR],
            [TwelveMCPR],
            [DTC],
            [KeyRateDur6M],
            [KeyRateDur1Yr],
            [KeyRateDur2y],
            [KeyRateDur3y],
            [KeyRateDur5y],
            [KeyRateDur7y],
            [KeyRateDur10y],
            [WAC],
            [WAM],
            [ModifiedDur],
            [SpreadDur],
            [OAS],
            [Convexity],
            [AdjustedDur],
            [YTM],
            [FIGI],
            [SYMBOL],
            [CUSIP],
            [ISIN],
            [SEDOL],
            [PE],
            [Beta],
            [Identifier],
            [ENV],
            [SOC],
            [GOV],
            [ESG],
            [Ratings],
            [PFBMCode],
            [PFBMSecurityKey],
            [AsOfDate],
            [Quantity],
            [IsPortfolio],
            [HoldingsMarketValue],
            [CreatedBy],
            [CreatedDate],
            [UpdatedBy],
            [UpdatedDate]
        FROM [ims].[vw_RptPosAnalyticsData];

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
                'sp_RptPosAnalyticsData'
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
            'sp_RptPosAnalyticsData'
        );

        THROW;

    END CATCH

END;

GO