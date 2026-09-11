CREATE TABLE [ims].[DS_PortfolioOptimization_Weights] (
    [RowId]          BIGINT          NOT NULL,
    [PortfolioId]    VARCHAR (50)    NOT NULL,
    [Ticker]         VARCHAR (20)    NOT NULL,
    [AsOfDate]       DATE            NOT NULL,
    [CurrentWeight]  DECIMAL (18, 6) NULL,
    [TargetWeight]   DECIMAL (18, 6) NULL,
    [WeightDelta]    DECIMAL (18, 6) NULL,
    [TradeAction]    VARCHAR (20)    NULL,
    [TradeSizeValue] DECIMAL (18, 4) NULL,
    [CreatedDate]    DATETIME2 (6)   NULL,
    [UpdatedDate]    DATETIME2 (6)   NULL
);


GO