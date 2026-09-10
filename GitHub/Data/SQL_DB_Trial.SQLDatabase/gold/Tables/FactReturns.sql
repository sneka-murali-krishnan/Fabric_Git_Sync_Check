CREATE TABLE [gold].[FactReturns] (
    [ReturnID]      INT             NOT NULL,
    [OrderDetailID] INT             NULL,
    [DateKey]       INT             NULL,
    [Reason]        VARCHAR (200)   NULL,
    [RefundAmount]  DECIMAL (10, 2) NULL,
    PRIMARY KEY CLUSTERED ([ReturnID] ASC)
);


GO

