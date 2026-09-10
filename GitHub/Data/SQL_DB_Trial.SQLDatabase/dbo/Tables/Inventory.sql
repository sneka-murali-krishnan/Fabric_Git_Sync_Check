CREATE TABLE [dbo].[Inventory] (
    [InventoryID]     INT  IDENTITY (1, 1) NOT NULL,
    [ProductID]       INT  NOT NULL,
    [WarehouseID]     INT  NOT NULL,
    [QuantityOnHand]  INT  NOT NULL,
    [LastRestockDate] DATE NOT NULL,
    PRIMARY KEY CLUSTERED ([InventoryID] ASC),
    FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    FOREIGN KEY ([WarehouseID]) REFERENCES [dbo].[Warehouses] ([WarehouseID])
);


GO

