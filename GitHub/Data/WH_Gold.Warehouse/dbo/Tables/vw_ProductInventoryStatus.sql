CREATE TABLE [dbo].[vw_ProductInventoryStatus] (

	[ProductID] int NULL, 
	[ProductName] varchar(100) NULL, 
	[UnitPrice] decimal(10,2) NULL, 
	[TotalOnHand] int NULL, 
	[StockStatus] varchar(9) NULL
);