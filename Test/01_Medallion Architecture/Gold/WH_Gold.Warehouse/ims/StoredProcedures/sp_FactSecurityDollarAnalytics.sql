-- ============================== Source file: FactSecurityDollarAnalytics_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactSecurityDollarAnalytics]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactSecurityDollarAnalytics';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'FactSecurityDollarAnalytics_Gold_Process';
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

        -- ---- Target: ims.FactSecurityDollarAnalytics ----
        IF OBJECT_ID(N'ims.FactSecurityDollarAnalytics', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactSecurityDollarAnalytics does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactSecurityDollarAnalytics;

        SET @SQL = N'INSERT INTO ims.FactSecurityDollarAnalytics (
            FactSecurityDollarAnalyticsKey,
            SecurityKey, AssetClassKey, SecurityTypeKey, CurrencyKey, CountryKey, SourceSystemKey,
            --DateKey, 

            SecurityId,
            EffectiveDt, NextDividendPaydate, LastDividendPaydate, PriceStartDay,
            PriceLastEOD, DividendYield, DividendAmount, FiftyTwoWeekHigh, FiftyTwoWeekLow,
            CurrentYearHigh, CurrentYearLow, MarketPrice, Factor, OneMCPR, ThreeMCPR,
            SixMCPR, TwelveMCPR, DTC, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
        )
        SELECT
            @MaxIDParam + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS FactSecurityDollarAnalyticsKey,
            ds.SecurityKey, ds.AssetClassKey, ds.SecurityTypeKey, ds.CurrencyKey, ds.CountryKey,  ds.SourceSystemKey, 
            --dd.DateKey, 
            sda.SecurityId,
            cast(sda.EffectiveDt as Date) as EffectiveDt, sda.NextDivideendPaydate, sda.LastDivideendPaydate, sda.PriceStartDay, 
            sda.PriceLastEOD, sda.DivideEndYield, sda.DividendAmount, sda.FiftyTwoWeekHigh, sda.FiftyTwoWeekLow, 
            sda.CurrentYearHigh, sda.CurrentYearLow, sda.MarketPrice, sda.Factor, sda.[1mCPR], sda.[3mCPR], 
            sda.[6mCPR], sda.[12mCPR], sda.DTC, sda.CreatedBy, sda.CreatedDate, sda.UpdatedBy, sda.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.dbo.securitydollaranalytics sda
        INNER JOIN ims.DimSecurity ds ON sda.SecurityId = ds.SecurityId
        
        LEFT JOIN ims.FactSecurityDollarAnalytics f 
            ON f.SecurityId = sda.SecurityId AND cast(sda.EffectiveDt as Date) = f.EffectiveDt;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in FactSecurityDollarAnalytics_Gold_Process';
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