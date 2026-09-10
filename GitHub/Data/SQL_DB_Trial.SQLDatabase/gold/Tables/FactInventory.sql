CREATE TABLE [gold].[FactInventory] (
    [InventoryID]    INT NOT NULL,
    [ProductID]      INT NULL,
    [WarehouseID]    INT NULL,
    [QuantityOnHand] INT NULL,
    [DateKey]        INT NULL,
    PRIMARY KEY CLUSTERED ([InventoryID] ASC)
);


GO

