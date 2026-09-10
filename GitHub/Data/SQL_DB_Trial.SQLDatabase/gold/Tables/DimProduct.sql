CREATE TABLE [gold].[DimProduct] (
    [ProductID]    INT             NOT NULL,
    [ProductName]  VARCHAR (100)   NULL,
    [CategoryName] VARCHAR (100)   NULL,
    [SupplierName] VARCHAR (100)   NULL,
    [UnitPrice]    DECIMAL (10, 2) NULL,
    PRIMARY KEY CLUSTERED ([ProductID] ASC)
);


GO

