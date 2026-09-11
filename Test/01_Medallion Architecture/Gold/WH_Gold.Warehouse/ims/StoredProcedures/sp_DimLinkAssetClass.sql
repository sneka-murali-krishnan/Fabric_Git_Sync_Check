-- ============================== Source file: LinkAssetClass_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimLinkAssetClass]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimLinkAssetClass';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'LinkAssetClass_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimLinkAssetClass ----
        IF OBJECT_ID(N'ims.DimLinkAssetClass', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimLinkAssetClass does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimLinkAssetClass;

        SET @SQL = N'INSERT INTO ims.DimLinkAssetClass (
            LinkAssetClassKey,
            AssetClassCode,
            AssetClassName,
            ParentAssetClassCode,
            ParentAssetClassName,
            CustomerAssetClassCode,
            CustomerAssetClassName,
            ParentCustomerAssetClassCode,
            ParentCustomerAssetClassName,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.LinkAssetClassKey,
            s.AssetClassCode,
            ac.Name,
            s.AssetClassParentCode,
            pac.Name,
            s.CustomerAssetClassCode,
            cac.Name,
            s.CustomerAssetClassParentCode,
            pcac.Name,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].LinkAssetClass s
        LEFT JOIN ims.DimLinkAssetClass d
            ON s.LinkAssetClassKey = d.LinkAssetClassKey
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].AssetClass ac
            ON ac.AssetClassId = s.AssetClassId
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].AssetClass pac
            ON pac.AssetClassId = s.AssetClassParentID
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].AssetClass cac
            ON cac.AssetClassId = s.CustomerAssetClassId
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].AssetClass pcac
            ON pcac.AssetClassId = s.CustomerAssetClassParentId;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimLinkAssetClassExt ----
        IF OBJECT_ID(N'ims.DimLinkAssetClassExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimLinkAssetClassExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimLinkAssetClassExt;

        SET @SQL = N'INSERT INTO ims.DimLinkAssetClassExt (
            LinkAssetClassKey
        )
        SELECT
            s.LinkAssetClassKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].LinkAssetClassExt s
        LEFT JOIN ims.DimLinkAssetClassExt d ON s.LinkAssetClassKey = d.LinkAssetClassKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in LinkAssetClass_Gold_Process';
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