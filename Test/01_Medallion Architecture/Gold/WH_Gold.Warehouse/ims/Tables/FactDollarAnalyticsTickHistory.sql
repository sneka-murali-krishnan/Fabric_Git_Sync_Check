CREATE TABLE [ims].[FactDollarAnalyticsTickHistory] (
    [SecurityKey]         BIGINT          NULL,
    [LinkAssetClassKey]   BIGINT          NULL,
    [LinkSecurityTypeKey] BIGINT          NULL,
    [CurrencyKey]         BIGINT          NULL,
    [CountryKey]          BIGINT          NULL,
    [SourceSystemKey]     BIGINT          NULL,
    [DateKey]             BIGINT          NULL,
    [EffectiveDt]         DATE            NULL,
    [NextDividendPaydate] DATE            NULL,
    [LastDividendPaydate] DATE            NULL,
    [PriceStartDay]       DECIMAL (18, 4) NULL,
    [PriceLastEOD]        DECIMAL (18, 4) NULL,
    [DividendYield]       DECIMAL (18, 4) NULL,
    [DividendAmount]      DECIMAL (18, 4) NULL,
    [FiftyTwoWeekHigh]    DECIMAL (18, 4) NULL,
    [FiftyTwoWeekLow]     DECIMAL (18, 4) NULL,
    [CurrentYearHigh]     DECIMAL (18, 4) NULL,
    [CurrentYearLow]      DECIMAL (18, 4) NULL,
    [MarketPrice]         DECIMAL (18, 4) NULL,
    [Factor]              DECIMAL (18, 4) NULL,
    [OneMCPR]             DECIMAL (18, 4) NULL,
    [ThreeMCPR]           DECIMAL (18, 4) NULL,
    [SixMCPR]             DECIMAL (18, 4) NULL,
    [TwelveMCPR]          DECIMAL (18, 4) NULL,
    [DTC]                 DECIMAL (18, 4) NULL,
    [CreatedBy]           VARCHAR (8000)  NULL,
    [CreatedDate]         DATETIME2 (6)   NULL,
    [UpdatedBy]           VARCHAR (8000)  NULL,
    [UpdatedDate]         DATETIME2 (6)   NULL
);


GO