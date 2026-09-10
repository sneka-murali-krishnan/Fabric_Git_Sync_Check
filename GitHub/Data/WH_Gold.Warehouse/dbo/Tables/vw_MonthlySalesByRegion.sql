CREATE TABLE [dbo].[vw_MonthlySalesByRegion] (

	[RegionID] int NULL, 
	[RegionName] varchar(100) NULL, 
	[SalesMonth] date NULL, 
	[MonthlySales] decimal(38,2) NULL
);