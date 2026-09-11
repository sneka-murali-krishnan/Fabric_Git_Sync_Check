CREATE TABLE [ims].[DS_PortfolioOptimization_Performance] (
    [RowId]       BIGINT          NOT NULL,
    [PortfolioId] VARCHAR (50)    NOT NULL,
    [PeriodStart] DATE            NOT NULL,
    [PeriodEnd]   DATE            NOT NULL,
    [NetReturn]   DECIMAL (18, 6) NULL,
    [Sharpe]      DECIMAL (18, 6) NULL,
    [MaxDrawdown] DECIMAL (18, 6) NULL,
    [Turnover]    DECIMAL (18, 6) NULL,
    [CreatedDate] DATETIME2 (6)   NULL,
    [UpdatedDate] DATETIME2 (6)   NULL
);


GO