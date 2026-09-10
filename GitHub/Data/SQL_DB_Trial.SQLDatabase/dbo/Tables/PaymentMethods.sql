CREATE TABLE [dbo].[PaymentMethods] (
    [PaymentMethodID] INT          IDENTITY (1, 1) NOT NULL,
    [MethodName]      VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([PaymentMethodID] ASC)
);


GO

