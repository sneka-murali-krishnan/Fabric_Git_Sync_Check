CREATE TABLE [ims].[RptPerformanceAttribution] (
    [PFBMCode]                   VARCHAR (8000)   NULL,
    [EffectiveDt]                DATE             NULL,
    [ESG]                        DECIMAL (18, 4)  NULL,
    [Ratings]                    DECIMAL (18, 4)  NULL,
    [SectorGICS]                 VARCHAR (8000)   NULL,
    [HoldingsMarketValue]        DECIMAL (18, 4)  NULL,
    [EffectiveDtMonth]           DATE             NULL,
    [EffectiveDtQuarter]         DATE             NULL,
    [EffectiveDtYear]            DATE             NULL,
    [HoldingsMarketValueMonth]   DECIMAL (18, 4)  NULL,
    [HoldingsMarketValueQuarter] DECIMAL (18, 4)  NULL,
    [HoldingsMarketValueYear]    DECIMAL (18, 4)  NULL,
    [MarketValueReturnMonth]     DECIMAL (38, 19) NULL,
    [MarketValueReturnQuarter]   DECIMAL (38, 19) NULL,
    [MarketValueReturnYear]      DECIMAL (38, 19) NULL
);


GO