CREATE TABLE [dbo].[Payments] (
    [PaymentID]       INT             IDENTITY (1, 1) NOT NULL,
    [OrderID]         INT             NOT NULL,
    [PaymentMethodID] INT             NOT NULL,
    [Amount]          DECIMAL (10, 2) NOT NULL,
    [PaymentDate]     DATE            NOT NULL,
    PRIMARY KEY CLUSTERED ([PaymentID] ASC),
    FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders] ([OrderID]),
    FOREIGN KEY ([PaymentMethodID]) REFERENCES [dbo].[PaymentMethods] ([PaymentMethodID])
);


GO

