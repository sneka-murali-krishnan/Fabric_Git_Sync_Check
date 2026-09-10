
/* =====================================================================
   3. VIEWS (dbo) — 5 reporting views over source tables
   ===================================================================== */

CREATE   VIEW dbo.vw_SalesSummary AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.CustomerID,
    o.StoreID,
    SUM(od.Quantity * od.UnitPrice) AS OrderTotal,
    COUNT(od.OrderDetailID)         AS LineItemCount
FROM dbo.Orders o
JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
GROUP BY o.OrderID, o.OrderDate, o.CustomerID, o.StoreID;

GO

