
-- 9. FactInventory
CREATE   PROCEDURE gold.sp_BuildFactInventory
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.FactInventory;

    INSERT INTO gold.FactInventory (InventoryID, ProductID, WarehouseID, QuantityOnHand, DateKey)
    SELECT
        InventoryID, ProductID, WarehouseID, QuantityOnHand,
        CONVERT(INT, FORMAT(LastRestockDate, 'yyyyMMdd'))
    FROM dbo.Inventory;
END

GO

