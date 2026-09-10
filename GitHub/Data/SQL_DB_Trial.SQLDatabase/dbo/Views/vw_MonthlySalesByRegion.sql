
CREATE   VIEW dbo.vw_MonthlySalesByRegion AS
SELECT
    r.RegionID,
    r.RegionName,
    DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
    SUM(od.Quantity * od.UnitPrice) AS MonthlySales
FROM dbo.Orders o
JOIN dbo.Stores s      ON s.StoreID = o.StoreID
JOIN dbo.Regions r     ON r.RegionID = s.RegionID
JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
GROUP BY r.RegionID, r.RegionName, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1);

GO

