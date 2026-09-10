
-- 8. FactReturns
CREATE   PROCEDURE gold.sp_BuildFactReturns
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.FactReturns;

    INSERT INTO gold.FactReturns (ReturnID, OrderDetailID, DateKey, Reason, RefundAmount)
    SELECT
        ReturnID, OrderDetailID,
        CONVERT(INT, FORMAT(ReturnDate, 'yyyyMMdd')),
        Reason, RefundAmount
    FROM dbo.Returns;
END

GO

