CREATE TABLE [dbo].[Warehouses] (
    [WarehouseID]   INT           IDENTITY (1, 1) NOT NULL,
    [WarehouseName] VARCHAR (100) NOT NULL,
    [RegionID]      INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([WarehouseID] ASC),
    FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Regions] ([RegionID])
);


GO

