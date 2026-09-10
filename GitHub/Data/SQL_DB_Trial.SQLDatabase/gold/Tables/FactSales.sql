CREATE TABLE [gold].[FactSales] (
    [OrderDetailID] INT             NOT NULL,
    [OrderID]       INT             NULL,
    [DateKey]       INT             NULL,
    [CustomerID]    INT             NULL,
    [ProductID]     INT             NULL,
    [StoreID]       INT             NULL,
    [EmployeeID]    INT             NULL,
    [Quantity]      INT             NULL,
    [UnitPrice]     DECIMAL (10, 2) NULL,
    [LineTotal]     DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([OrderDetailID] ASC)
);


GO

