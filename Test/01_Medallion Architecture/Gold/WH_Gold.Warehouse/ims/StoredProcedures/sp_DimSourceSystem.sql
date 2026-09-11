-- ============================== Source file: SourceSystem_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimSourceSystem]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimSourceSystem';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'SourceSystem_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimSourceSystem ----
        IF OBJECT_ID(N'ims.DimSourceSystem', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimSourceSystem does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimSourceSystem;

        SET @SQL = N'INSERT INTO ims.DimSourceSystem (
            SourceSystemKey, SourceSystemId, Code, Name, SourceSystemTypeCode,
            SourceSystemTypeName, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
        )
        SELECT
            ss.SourceSystemKey,
            ss.SourceSystemId,
            ss.Code,
            ss.Name,
            ss.SourceSystemTypeCode,
            sst.Name AS SourceSystemTypeName,
            ss.CreatedBy,
            ss.CreatedDate,
            ss.UpdatedBy,
            ss.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SourceSystem ss
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SourceSystemType sst ON ss.SourceSystemTypeCode = sst.Code
        LEFT JOIN ims.DimSourceSystem dim ON ss.SourceSystemKey = dim.SourceSystemKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimSourceSystemExt ----
        IF OBJECT_ID(N'ims.DimSourceSystemExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimSourceSystemExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimSourceSystemExt;

        SET @SQL = N'INSERT INTO ims.DimSourceSystemExt (
            SourceSystemKey
        )
        SELECT
            source.SourceSystemKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SourceSystem source
        LEFT JOIN ims.DimSourceSystemExt target on source.SourceSystemKey = target.SourceSystemKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in SourceSystem_Gold_Process';
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