CREATE TABLE [ims].[RptPortfolioAnalytics] (
    [PFBMCode]       VARCHAR (8000)  NULL,
    [EffectiveDt]    DATETIME2 (6)   NULL,
    [Identifier]     VARCHAR (8000)  NULL,
    [ShortName]      VARCHAR (8000)  NULL,
    [AssetClassName] VARCHAR (8000)  NULL,
    [IndustryGICS]   VARCHAR (8000)  NULL,
    [MarketPrice]    DECIMAL (18, 4) NULL,
    [Quantity]       DECIMAL (18, 4) NULL,
    [MarketValue]    DECIMAL (37, 8) NULL,
    [PE]             DECIMAL (18, 4) NULL,
    [Beta]           DECIMAL (18, 4) NULL,
    [OneMCPR]        DECIMAL (18, 4) NULL,
    [ThreeMCPR]      DECIMAL (18, 4) NULL,
    [SixMCPR]        DECIMAL (18, 4) NULL,
    [TwelveMCPR]     DECIMAL (18, 4) NULL,
    [KeyRateDur6M]   DECIMAL (18, 4) NULL,
    [KeyRateDur1Yr]  DECIMAL (18, 4) NULL,
    [KeyRateDur3y]   DECIMAL (18, 4) NULL,
    [KeyRateDur5y]   DECIMAL (18, 4) NULL,
    [KeyRateDur7y]   DECIMAL (18, 4) NULL
);


GO