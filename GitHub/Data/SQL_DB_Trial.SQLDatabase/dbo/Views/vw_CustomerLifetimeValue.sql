
CREATE   VIEW dbo.vw_CustomerLifetimeValue AS
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT o.OrderID)              AS TotalOrders,
    ISNULL(SUM(od.Quantity * od.UnitPrice), 0) AS LifetimeSpend
FROM dbo.Customers c
LEFT JOIN dbo.Orders o        ON o.CustomerID = c.CustomerID
LEFT JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.CustomerName;

GO

