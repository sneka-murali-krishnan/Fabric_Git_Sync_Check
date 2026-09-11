-- ============================== Source file: FactSecurityRiskAnalytics_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactSecurityRiskAnalytics]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactSecurityRiskAnalytics';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'FactSecurityRiskAnalytics_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);
    DECLARE @MaxID BIGINT = 0;

    BEGIN TRY

        -- ---- Target: ims.FactSecurityRiskAnalytics ----
        IF OBJECT_ID(N'ims.FactSecurityRiskAnalytics', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactSecurityRiskAnalytics does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactSecurityRiskAnalytics;

        SET @SQL = N'INSERT INTO ims.FactSecurityRiskAnalytics (
            FactSecurityRiskAnalyticsKey,
            SecurityKey, AssetClassKey, SecurityTypeKey, CurrencyKey, CountryKey, 
            --SourceSystemKey,
            --DateKey, 
            SecurityId,
            EffectiveDt, EquityVolatility, PERatio, 
            KeyRateDur6M, KeyRateDur1Yr, KeyRateDur2y, KeyRateDur3y, KeyRateDur5y, KeyRateDur7y, KeyRateDur10y,
            Factor, WAC, WAM, ModifiedDur, SpreadDur, OAS, Convexity, AdjustedDur, YTM,
            CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
        )
        SELECT
            @MaxIDParam + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS FactSecurityRiskAnalyticsKey, 
            ds.SecurityKey, ds.AssetClassKey, ds.SecurityTypeKey, ds.CurrencyKey, ds.CountryKey,  
            --ds.SourceSystemKey, 
            --dd.DateKey, 
            sra.SecurityId,
            cast(sra.EffectiveDt as Date) as EffectiveDt, sra.EquityVolatility, sra.PERatio,
            sra.KeyRateDur6M, sra.KeyRateDur1Yr, sra.KeyRateDur2y, sra.KeyRateDur3y,sra.KeyRateDur5y, sra.KeyRateDur7y, sra.KeyRateDur10y, 
            sra.Factor, sra.WAC, sra.WAM, sra.ModifiedDur, sra.SpreadDur, sra.OAS, sra.Convexity, sra.AdjustedDur, sra.YTM, 
            sra.CreatedBy, sra.CreatedDate, sra.UpdatedBy, sra.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].securityriskanalytics sra
  
        INNER JOIN ims.DimSecurity ds ON sra.SecurityId = ds.SecurityId
        
        LEFT JOIN ims.FactSecurityRiskAnalytics f 
            ON f.SecurityId = sra.SecurityId AND cast(sra.EffectiveDt as Date) = f.EffectiveDt;';
        EXEC sp_executesql @SQL, N'@MaxIDParam BIGINT', @MaxIDParam = @MaxID;
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in FactSecurityRiskAnalytics_Gold_Process';
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