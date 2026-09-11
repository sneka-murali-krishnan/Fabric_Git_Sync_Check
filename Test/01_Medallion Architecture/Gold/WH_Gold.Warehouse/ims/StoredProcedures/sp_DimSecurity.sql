-- ============================== Source file: Security_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimSecurity]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimSecurity';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'Security_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimSecurity ----
        IF OBJECT_ID(N'ims.DimSecurity', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimSecurity does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimSecurity;

        SET @SQL = N'INSERT INTO ims.DimSecurity (
            SecurityKey, LinkAssetClassKey, LinkSecurityTypeKey, FIGI, CurrencyKey, CountryKey,
            ShortName, LongName, SecurityDescription, SourceSystemKey, IndustryGICS,
            SubindustryGICS, SectorGICS, IndustryGroupGICS, SubSectorGICS,
            LatestEffectiveDt, OrginationDt, Coupon, ContractSize, TotalShares, MaturityDate,
            CreatedBy, CreatedDate, UpdatedBy, UpdatedDate, IssuerKey
        )
        SELECT
            s.SecurityKey,
            ac.LinkAssetClassKey, st.LinkSecurityTypeKey, s.FIGI, cu.CurrencyKey, co.CountryKey,
            s.ShortName, s.LongName, s.SecurityDescription, s.SourceSystemKey, s.IndustryGICS,
            s.SubindustryGICS, s.SectorGICS, s.IndustryGroupGICS, s.SubSectorGICS,
            s.LatestEffectiveDt, s.OrginationDt, s.Coupon, s.ContractSize, s.TotalShares, s.MaturityDate,
            s.CreatedBy, s.CreatedDate, s.UpdatedBy, s.UpdatedDate, si.IssuerKey  -- Only get IssuerKey if IdentifierType is ''SYMBOL''
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Security s
        LEFT JOIN ims.DimLinkAssetClass ac ON ac.LinkAssetClassKey = s.LinkAssetClassKey
        LEFT JOIN ims.DimCountry co ON co.CountryKey = s.CountryKey
        LEFT JOIN ims.DimCurrency cu ON cu.CurrencyKey = s.CurrencyKey
        LEFT JOIN ims.DimLinkSecurityType st ON st.LinkSecurityTypeKey = s.LinkSecurityTypeKey
        LEFT JOIN (
            SELECT
                dsi.SecurityKey,
                dsi.Identifier,
                dsi.IdentifierType,
                i.IssuerKey
            FROM ims.DimSecurityIdentifier dsi
            LEFT JOIN ims.DimIssuer i ON dsi.Identifier COLLATE Latin1_General_CI_AS = i.Code COLLATE Latin1_General_CI_AS
            WHERE dsi.IdentifierType = ''SYMBOL''
        ) AS si ON si.SecurityKey = s.SecurityKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimSecurityIdentifier ----
        IF OBJECT_ID(N'ims.DimSecurityIdentifier', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimSecurityIdentifier does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimSecurityIdentifier;

        SET @SQL = N'INSERT INTO ims.DimSecurityIdentifier (
            SecurityKey,
            IdentifierType,
            Identifier,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            sec.SecurityKey,
            s.IdentifierType,
            s.Identifier,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityIdentifier s

        LEFT JOIN ims.DimSecurity sec
            ON s.SecurityKey = sec.SecurityKey

        LEFT JOIN ims.DimSecurityIdentifier d
            ON s.SecurityKey = d.SecurityKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimSecurityExt ----
        IF OBJECT_ID(N'ims.DimSecurityExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimSecurityExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimSecurityExt;

        SET @SQL = N'INSERT INTO ims.DimSecurityExt (
            SecurityKey
        )
        SELECT
            s.SecurityKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityExt s
        LEFT JOIN ims.DimSecurityExt d ON s.SecurityKey = d.SecurityKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimSecurityIdentifierExt ----
        IF OBJECT_ID(N'ims.DimSecurityIdentifierExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimSecurityIdentifierExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimSecurityIdentifierExt;

        SET @SQL = N'INSERT INTO ims.DimSecurityIdentifierExt (
            SecurityKey
        )
        SELECT
            s.SecurityKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityIdentifierExt s
        LEFT JOIN ims.DimSecurityIdentifierExt d ON s.SecurityKey = d.SecurityKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Security_Gold_Process';
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