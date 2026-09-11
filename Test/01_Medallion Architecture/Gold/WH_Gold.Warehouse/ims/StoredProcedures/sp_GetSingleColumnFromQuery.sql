-- ============================== Source file: sp_GetSingleColumnFromQuery.sql ==============================
CREATE   PROCEDURE [ims].[sp_GetSingleColumnFromQuery]
(
    -- Defaults added so MasterExecuter can run this generic dynamic-SQL
    -- helper as part of the automated batch without erroring on a missing
    -- required parameter. With no args it degrades to a harmless no-op
    -- health check (SELECT 1); real callers still pass a real query.
    @Query NVARCHAR(MAX) = N'SELECT 1 AS DummyValue',
    @ColumnName NVARCHAR(255) = N'DummyValue'
)
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL =
        N'SELECT ' + QUOTENAME(@ColumnName) + N'
          FROM
          (
              ' + @Query + N'
          ) AS SubQuery';

    EXEC sp_executesql @SQL;

END;

GO