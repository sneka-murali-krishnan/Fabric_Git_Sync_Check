CREATE TABLE [gold].[FactPayments] (
    [PaymentID]       INT             NOT NULL,
    [OrderID]         INT             NULL,
    [DateKey]         INT             NULL,
    [PaymentMethodID] INT             NULL,
    [Amount]          DECIMAL (10, 2) NULL,
    PRIMARY KEY CLUSTERED ([PaymentID] ASC)
);


GO

