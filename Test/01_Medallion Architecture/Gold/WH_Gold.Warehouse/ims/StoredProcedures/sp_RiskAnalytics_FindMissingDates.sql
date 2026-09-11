-- ============================== Source file: sp_RiskAnalytics_FindMissingDates.sql ==============================
CREATE   PROCEDURE [ims].[sp_RiskAnalytics_FindMissingDates]
(
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @StartDate = ISNULL
    (
        @StartDate,
        DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
    );

    SET @EndDate = ISNULL
    (
        @EndDate,
        CAST(GETDATE() AS DATE)
    );

    SELECT DISTINCT
        CAST(d.[Date] AS DATE) AS dt
    FROM dbo.[Date] d
    LEFT JOIN [FinIn_DE_LH_BRONZE_AND_SILVER].[dbo].[RiskAnalytics] fra
        ON fra.[EffectiveDt] = d.[Date]
    WHERE d.[Date] BETWEEN @StartDate AND @EndDate
      AND DATEPART(WEEKDAY, d.[Date]) BETWEEN 2 AND 6
      AND fra.[EffectiveDt] IS NULL
    ORDER BY dt;

END;

GO