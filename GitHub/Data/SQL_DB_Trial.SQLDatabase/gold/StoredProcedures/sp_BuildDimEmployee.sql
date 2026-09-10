
-- 5. DimEmployee
CREATE   PROCEDURE gold.sp_BuildDimEmployee
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.DimEmployee;

    INSERT INTO gold.DimEmployee (EmployeeID, EmployeeName, Role, StoreID, HireDate)
    SELECT EmployeeID, EmployeeName, Role, StoreID, HireDate
    FROM dbo.Employees;
END

GO

