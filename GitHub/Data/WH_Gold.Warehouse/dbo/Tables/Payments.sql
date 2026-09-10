CREATE TABLE [dbo].[Payments] (

	[PaymentID] int NULL, 
	[OrderID] int NULL, 
	[PaymentMethodID] int NULL, 
	[Amount] decimal(10,2) NULL, 
	[PaymentDate] date NULL
);