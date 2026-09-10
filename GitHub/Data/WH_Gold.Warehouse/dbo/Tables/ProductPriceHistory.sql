CREATE TABLE [dbo].[ProductPriceHistory] (

	[PriceHistoryID] int NULL, 
	[ProductID] int NULL, 
	[OldPrice] decimal(10,2) NULL, 
	[NewPrice] decimal(10,2) NULL, 
	[ChangeDate] date NULL
);