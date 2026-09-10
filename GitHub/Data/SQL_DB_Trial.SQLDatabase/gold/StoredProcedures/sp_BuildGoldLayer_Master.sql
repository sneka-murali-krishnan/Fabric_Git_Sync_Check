
/* =====================================================================
   6. MASTER STORED PROCEDURE — builds the full gold layer in order
   ===================================================================== */

CREATE   PROCEDURE gold.sp_BuildGoldLayer_Master
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @step VARCHAR(100);
    DECLARE @startTime DATETIME2 = SYSUTCDATETIME();

    BEGIN TRY
        SET @step = 'DimDate';         EXEC gold.sp_BuildDimDate;
        SET @step = 'DimCustomer';     EXEC gold.sp_BuildDimCustomer;
        SET @step = 'DimProduct';      EXEC gold.sp_BuildDimProduct;
        SET @step = 'DimStore';        EXEC gold.sp_BuildDimStore;
        SET @step = 'DimEmployee';     EXEC gold.sp_BuildDimEmployee;
        SET @step = 'FactSales';       EXEC gold.sp_BuildFactSales;
        SET @step = 'FactPayments';    EXEC gold.sp_BuildFactPayments;
        SET @step = 'FactReturns';     EXEC gold.sp_BuildFactReturns;
        SET @step = 'FactInventory';   EXEC gold.sp_BuildFactInventory;
        SET @step = 'AggMonthlySales'; EXEC gold.sp_BuildAggMonthlySales;

        PRINT CONCAT('Gold layer build completed successfully in ',
                      DATEDIFF(SECOND, @startTime, SYSUTCDATETIME()), ' seconds.');
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT CONCAT('Gold layer build FAILED at step [', @step, ']: ', @errMsg);
        THROW;
    END CATCH
END

GO

