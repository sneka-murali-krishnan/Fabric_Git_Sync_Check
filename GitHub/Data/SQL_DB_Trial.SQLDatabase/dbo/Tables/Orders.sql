CREATE TABLE [dbo].[Orders] (
    [OrderID]     INT  IDENTITY (1, 1) NOT NULL,
    [CustomerID]  INT  NOT NULL,
    [StoreID]     INT  NOT NULL,
    [EmployeeID]  INT  NOT NULL,
    [OrderDate]   DATE NOT NULL,
    [PromotionID] INT  NULL,
    PRIMARY KEY CLUSTERED ([OrderID] ASC),
    FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]),
    FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID]),
    FOREIGN KEY ([PromotionID]) REFERENCES [dbo].[Promotions] ([PromotionID]),
    FOREIGN KEY ([StoreID]) REFERENCES [dbo].[Stores] ([StoreID])
);


GO

