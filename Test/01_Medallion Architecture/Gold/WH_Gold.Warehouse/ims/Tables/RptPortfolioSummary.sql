CREATE TABLE [ims].[RptPortfolioSummary] (
    [Identifier]        VARCHAR (8000)  NULL,
    [MarketValue]       DECIMAL (37, 8) NULL,
    [AssetClass]        VARCHAR (8000)  NULL,
    [ESG]               DECIMAL (18, 4) NULL,
    [ESGGroup]          VARCHAR (8000)  NULL,
    [ESGGroupSortOrder] INT             NULL,
    [PFBMCode]          VARCHAR (8000)  NULL,
    [EffectiveDt]       DATETIME2 (6)   NULL
);


GO