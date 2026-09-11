-- ============================== Source file: StandardSourceField_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimStandardSourceField]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimStandardSourceField';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'StandardSourceField_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimStandardSourceField ----
        IF OBJECT_ID(N'ims.DimStandardSourceField', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimStandardSourceField does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimStandardSourceField;

        SET @SQL = N'INSERT INTO ims.DimStandardSourceField (
            StandardSourceFieldKey,
            Code,
            Name,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.StandardSourceFieldKey,
            s.Code,
            s.Name,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StandardSourceFields s
        LEFT JOIN ims.DimStandardSourceField d
            ON s.StandardSourceFieldKey = d.StandardSourceFieldKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimStandardSourceFieldExt ----
        IF OBJECT_ID(N'ims.DimStandardSourceFieldExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimStandardSourceFieldExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimStandardSourceFieldExt;

        SET @SQL = N'INSERT INTO ims.DimStandardSourceFieldExt (
            StandardSourceFieldKey
        )
        SELECT
            s.StandardSourceFieldKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StandardSourceFieldsExt s
        LEFT JOIN ims.DimStandardSourceFieldExt d ON s.StandardSourceFieldKey = d.StandardSourceFieldKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' Seconds';

        BEGIN TRY
            INSERT INTO [WH_MetaData].[Log].[ETLBatchGoldLogDetails]
            (
                BatchId,
                SchemaName,
                TableName,
                ProcessedRowCount,
                StartTime,
                EndTime,
                Status,
                ErrorMessage,
                SourceName
            )
            VALUES
            (
                @BatchId,
                @SchemaName,
                @TableName,
                @RowsInserted,
                @StartTime,
                @EndTime,
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE() + ' in StandardSourceField_Gold_Process';
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' Seconds';

        BEGIN TRY
            INSERT INTO [WH_MetaData].[Log].[ETLBatchGoldLogDetails]
            (
                BatchId,
                SchemaName,
                TableName,
                ProcessedRowCount,
                StartTime,
                EndTime,
                Status,
                ErrorMessage,
                SourceName
            )
            VALUES
            (
                @BatchId,
                @SchemaName,
                @TableName,
                0,
                @StartTime,
                @EndTime,
                'Failed',
                @ErrorMessage,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- swallow logging errors so they never mask the real failure
        END CATCH
    END CATCH
END

GO