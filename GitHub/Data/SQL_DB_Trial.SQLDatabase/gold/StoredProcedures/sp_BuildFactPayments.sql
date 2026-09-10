
-- 7. FactPayments
CREATE   PROCEDURE gold.sp_BuildFactPayments
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE gold.FactPayments;

    INSERT INTO gold.FactPayments (PaymentID, OrderID, DateKey, PaymentMethodID, Amount)
    SELECT
        PaymentID, OrderID,
        CONVERT(INT, FORMAT(PaymentDate, 'yyyyMMdd')),
        PaymentMethodID, Amount
    FROM dbo.Payments;
END

GO

