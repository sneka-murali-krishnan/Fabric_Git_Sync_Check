CREATE TABLE [dbo].[Returns] (

	[ReturnID] int NULL, 
	[OrderDetailID] int NULL, 
	[ReturnDate] date NULL, 
	[Reason] varchar(200) NULL, 
	[RefundAmount] decimal(10,2) NULL
);