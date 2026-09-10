CREATE TABLE [dbo].[vw_SalesSummary] (

	[OrderID] int NULL, 
	[OrderDate] date NULL, 
	[CustomerID] int NULL, 
	[StoreID] int NULL, 
	[OrderTotal] decimal(38,2) NULL, 
	[LineItemCount] int NULL
);