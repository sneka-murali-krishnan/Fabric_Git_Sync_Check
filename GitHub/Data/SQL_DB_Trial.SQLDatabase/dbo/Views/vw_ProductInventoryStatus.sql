
CREATE   VIEW dbo.vw_ProductInventoryStatus AS
SELECT
    p.ProductID,
    p.ProductName,
    p.UnitPrice,
    SUM(i.QuantityOnHand) AS TotalOnHand,
    CASE WHEN SUM(i.QuantityOnHand) < 50 THEN 'Low Stock' ELSE 'OK' END AS StockStatus
FROM dbo.Products p
LEFT JOIN dbo.Inventory i ON i.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.UnitPrice;

GO

