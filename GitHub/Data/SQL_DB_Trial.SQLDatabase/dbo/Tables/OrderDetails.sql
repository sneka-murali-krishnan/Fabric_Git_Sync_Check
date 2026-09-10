CREATE TABLE [dbo].[OrderDetails] (
    [OrderDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [OrderID]       INT             NOT NULL,
    [ProductID]     INT             NOT NULL,
    [Quantity]      INT             NOT NULL,
    [UnitPrice]     DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([OrderDetailID] ASC),
    FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders] ([OrderID]),
    FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);


GO

