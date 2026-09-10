CREATE TABLE [gold].[FactReturns] (

	[ReturnID] int NULL, 
	[OrderDetailID] int NULL, 
	[DateKey] int NULL, 
	[Reason] varchar(200) NULL, 
	[RefundAmount] decimal(10,2) NULL
);