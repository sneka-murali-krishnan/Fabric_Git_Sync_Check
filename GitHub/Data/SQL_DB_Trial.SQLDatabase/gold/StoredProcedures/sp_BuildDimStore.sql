
-- 4. DimStore
CREATE   PROCEDURE gold.sp_BuildDimStore
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.DimStore;

    INSERT INTO gold.DimStore (StoreID, StoreName, RegionName, CountryName, OpenDate)
    SELECT st.StoreID, st.StoreName, r.RegionName, co.CountryName, st.OpenDate
    FROM dbo.Stores st
    JOIN dbo.Regions r    ON r.RegionID = st.RegionID
    JOIN dbo.Countries co ON co.CountryID = r.CountryID;
END

GO

