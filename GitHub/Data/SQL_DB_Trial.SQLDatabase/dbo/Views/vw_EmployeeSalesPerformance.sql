
CREATE   VIEW dbo.vw_EmployeeSalesPerformance AS
SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.StoreID,
    COUNT(o.OrderID)                        AS OrdersHandled,
    ISNULL(SUM(od.Quantity * od.UnitPrice), 0) AS TotalSalesValue
FROM dbo.Employees e
LEFT JOIN dbo.Orders o        ON o.EmployeeID = e.EmployeeID
LEFT JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, e.EmployeeName, e.StoreID;

GO

