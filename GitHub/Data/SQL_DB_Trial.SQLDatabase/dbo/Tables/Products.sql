CREATE TABLE [dbo].[Products] (
    [ProductID]   INT             IDENTITY (1, 1) NOT NULL,
    [ProductName] VARCHAR (100)   NOT NULL,
    [CategoryID]  INT             NOT NULL,
    [SupplierID]  INT             NOT NULL,
    [UnitPrice]   DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductID] ASC),
    FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID]),
    FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID])
);


GO

