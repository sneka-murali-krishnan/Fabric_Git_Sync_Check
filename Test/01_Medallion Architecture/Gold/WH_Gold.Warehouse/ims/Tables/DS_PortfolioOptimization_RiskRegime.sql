CREATE TABLE [ims].[DS_PortfolioOptimization_RiskRegime] (
    [RowId]            BIGINT          NOT NULL,
    [PortfolioId]      VARCHAR (50)    NOT NULL,
    [EffectiveDate]    DATE            NOT NULL,
    [GARCH_Volatility] DECIMAL (18, 6) NULL,
    [VolatilityRegime] VARCHAR (20)    NULL,
    [PPO_AAPL]         DECIMAL (18, 6) NULL,
    [PPO_MSFT]         DECIMAL (18, 6) NULL,
    [CreatedDate]      DATETIME2 (6)   NULL,
    [UpdatedDate]      DATETIME2 (6)   NULL
);


GO