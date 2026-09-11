CREATE TABLE [ims].[RptPortfolioPeerComparison] (
    [PortfolioCode] VARCHAR (8000)  NULL,
    [Ticker]        VARCHAR (8000)  NULL,
    [FundName]      VARCHAR (8000)  NULL,
    [AsOfDate]      DATETIME2 (6)   NULL,
    [NetAssetValue] DECIMAL (38, 4) NULL,
    [Return1D]      DECIMAL (38, 4) NULL,
    [Return1W]      DECIMAL (38, 4) NULL,
    [Return1M]      DECIMAL (38, 4) NULL,
    [Return3M]      DECIMAL (38, 4) NULL,
    [Return1Y]      DECIMAL (38, 4) NULL,
    [Return3Y]      DECIMAL (38, 4) NULL,
    [Return5Y]      DECIMAL (38, 4) NULL
);


GO