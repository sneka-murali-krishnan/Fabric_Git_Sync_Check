
/* =====================================================================
   5. GOLD BUILD STORED PROCEDURES (10) — one per gold object
   ===================================================================== */

-- 1. DimDate
CREATE   PROCEDURE gold.sp_BuildDimDate
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.DimDate;

    ;WITH DateBounds AS (
        SELECT MIN(OrderDate) AS MinDate, MAX(OrderDate) AS MaxDate FROM dbo.Orders
    ),
    Numbers AS (
        SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.objects a CROSS JOIN sys.objects b
    )
    INSERT INTO gold.DimDate (DateKey, FullDate, [Year], [Month], MonthName, [Quarter])
    SELECT
        CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS DateKey,
        d AS FullDate,
        YEAR(d), MONTH(d), DATENAME(MONTH, d), DATEPART(QUARTER, d)
    FROM (
        SELECT DATEADD(DAY, n.n, db.MinDate) AS d
        FROM Numbers n
        CROSS JOIN DateBounds db
        WHERE DATEADD(DAY, n.n, db.MinDate) <= db.MaxDate
    ) x;
END

GO

