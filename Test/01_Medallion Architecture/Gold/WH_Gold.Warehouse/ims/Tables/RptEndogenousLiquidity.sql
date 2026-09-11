CREATE TABLE [ims].[RptEndogenousLiquidity] (
    [PortfolioCode]       VARCHAR (8000)  NULL,
    [ShortName]           VARCHAR (8000)  NULL,
    [Date]                DATETIME2 (6)   NULL,
    [HoldingsMarketValue] DECIMAL (37, 8) NULL,
    [LiquidationAmount]   DECIMAL (18, 4) NULL
);


GO