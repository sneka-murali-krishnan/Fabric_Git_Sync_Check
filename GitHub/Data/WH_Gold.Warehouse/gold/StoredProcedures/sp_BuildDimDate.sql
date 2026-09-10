CREATE   PROCEDURE gold.sp_BuildDimDate
AS
BEGIN
    TRUNCATE TABLE gold.DimDate;

    -- Generate dates without referencing sys.objects (Distributed-safe)
    ;WITH Digits AS (
        SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    ),
    Numbers AS (
        SELECT (d1.d + d2.d * 10 + d3.d * 100 + d4.d * 1000) AS n
        FROM Digits d1
        CROSS JOIN Digits d2
        CROSS JOIN Digits d3
        CROSS JOIN Digits d4
        WHERE (d1.d + d2.d * 10 + d3.d * 100 + d4.d * 1000) <= 4000
    ),
    DateBounds AS (
        SELECT MIN(OrderDate) AS MinDate, MAX(OrderDate) AS MaxDate FROM dbo.Orders
    )
    INSERT INTO gold.DimDate (DateKey, FullDate, [Year], [Month], MonthName, [Quarter])
    SELECT
        (YEAR(d) * 10000 + MONTH(d) * 100 + DAY(d)) AS DateKey,
        d AS FullDate,
        YEAR(d), 
        MONTH(d), 
        DATENAME(MONTH, d), 
        DATEPART(QUARTER, d)
    FROM (
        SELECT DATEADD(DAY, n.n, db.MinDate) AS d
        FROM Numbers n
        CROSS JOIN DateBounds db
        WHERE DATEADD(DAY, n.n, db.MinDate) <= db.MaxDate
    ) x;
END