
-- 10. AggMonthlySales (built from the view, i.e. "gold aggregate on top of gold facts")
CREATE   PROCEDURE gold.sp_BuildAggMonthlySales
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.AggMonthlySales;

    INSERT INTO gold.AggMonthlySales (RegionName, SalesMonth, MonthlySales)
    SELECT RegionName, SalesMonth, MonthlySales
    FROM dbo.vw_MonthlySalesByRegion;
END

GO

