
-- 6. FactSales (depends on DimDate being built for DateKey lookup)
CREATE   PROCEDURE gold.sp_BuildFactSales
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.FactSales;

    INSERT INTO gold.FactSales
        (OrderDetailID, OrderID, DateKey, CustomerID, ProductID, StoreID, EmployeeID, Quantity, UnitPrice, LineTotal)
    SELECT
        od.OrderDetailID,
        o.OrderID,
        CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd')),
        o.CustomerID,
        od.ProductID,
        o.StoreID,
        o.EmployeeID,
        od.Quantity,
        od.UnitPrice,
        CAST(od.Quantity * od.UnitPrice AS DECIMAL(12,2))
    FROM dbo.OrderDetails od
    JOIN dbo.Orders o ON o.OrderID = od.OrderID;
END

GO

