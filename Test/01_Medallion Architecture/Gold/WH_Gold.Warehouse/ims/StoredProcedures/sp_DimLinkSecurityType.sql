-- ============================== Source file: LinkSecurityType_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimLinkSecurityType]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimLinkSecurityType';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'LinkSecurityType_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimLinkSecurityType ----
        IF OBJECT_ID(N'ims.DimLinkSecurityType', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimLinkSecurityType does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimLinkSecurityType;

        SET @SQL = N'INSERT INTO ims.DimLinkSecurityType (
            LinkSecurityTypeKey,
            SecurityTypeCode,
            CustomerSecurityTypeCode,
            SecurityTypeName,
            CustomerSecurityTypeName,
            SecurityTypeKey,
            CustomerSecurityTypeKey,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.LinkSecurityTypeKey,
            CAST(s.SecurityTypeCode AS VARCHAR(64)),
            CAST(s.CustomerSecurityTypeCode AS VARCHAR(64)),
            CAST(st.Name AS VARCHAR(64)),
            CAST(cst.Name AS VARCHAR(64)),
            st.SecurityTypeKey,
            cst.SecurityTypeKey,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].LinkSecurityType s
        LEFT JOIN ims.DimLinkSecurityType d
            ON s.LinkSecurityTypeKey = d.LinkSecurityTypeKey
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityType st
            ON st.SecurityTypeId = s.SecurityTypeId
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityType cst
            ON cst.SecurityTypeId = s.CustomerSecurityTypeId;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimLinkSecurityTypeExt ----
        IF OBJECT_ID(N'ims.DimLinkSecurityTypeExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimLinkSecurityTypeExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimLinkSecurityTypeExt;

        SET @SQL = N'INSERT INTO ims.DimLinkSecurityTypeExt (
            LinkSecurityTypeKey
        )
        SELECT
            s.LinkSecurityTypeKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].LinkSecurityTypeExt s
        LEFT JOIN ims.DimLinkSecurityTypeExt d ON s.LinkSecurityTypeKey = d.LinkSecurityTypeKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in LinkSecurityType_Gold_Process';
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