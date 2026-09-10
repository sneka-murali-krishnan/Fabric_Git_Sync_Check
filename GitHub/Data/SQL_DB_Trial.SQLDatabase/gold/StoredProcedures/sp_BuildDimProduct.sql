
-- 3. DimProduct
CREATE   PROCEDURE gold.sp_BuildDimProduct
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.DimProduct;

    INSERT INTO gold.DimProduct (ProductID, ProductName, CategoryName, SupplierName, UnitPrice)
    SELECT p.ProductID, p.ProductName, cat.CategoryName, s.SupplierName, p.UnitPrice
    FROM dbo.Products p
    JOIN dbo.Categories cat ON cat.CategoryID = p.CategoryID
    JOIN dbo.Suppliers s    ON s.SupplierID = p.SupplierID;
END

GO

