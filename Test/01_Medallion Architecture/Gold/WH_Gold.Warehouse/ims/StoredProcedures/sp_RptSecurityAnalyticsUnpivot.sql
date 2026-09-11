-- ============================== Source file: sp_RptSecurityAnalyticsUnpivot.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptSecurityAnalyticsUnpivot]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver', -- not used in this procedure; source is a Gold-layer view
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptSecurityAnalyticsUnpivot';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256) = 'RptSecurityAnalyticsUnpivot_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Validate Target Table
        -----------------------------------------------------------------------
        IF OBJECT_ID(N'ims.RptSecurityAnalyticsUnpivot', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.RptSecurityAnalyticsUnpivot does not exist.', 1;
        END;

        -----------------------------------------------------------------------
        -- Full Refresh
        -----------------------------------------------------------------------
        TRUNCATE TABLE ims.RptSecurityAnalyticsUnpivot;

        INSERT INTO ims.RptSecurityAnalyticsUnpivot
        (
            [SecurityAnalyticsUnpivotKey],
            [SecurityKey],
            [LinkAssetClassKey],
            [LinkSecurityTypeKey],
            [CurrencyKey],
            [CountryKey],
            [ShortName],
            [LongName],
            [SecurityDescription],
            [SourceSystemKey],
            [IndustryGICS],
            [SubindustryGICS],
            [SectorGICS],
            [IndustryGroupGICS],
            [SubSectorGICS],
            [EffectiveDt],
            [NextDividendPaydate],
            [LastDividendPaydate],
            [Factor],
            [OneMCPR],
            [ThreeMCPR],
            [SixMCPR],
            [TwelveMCPR],
            [DTC],
            [KeyRateDur6M],
            [KeyRateDur1Yr],
            [KeyRateDur2y],
            [KeyRateDur3y],
            [KeyRateDur5y],
            [KeyRateDur7y],
            [KeyRateDur10y],
            [WAC],
            [WAM],
            [ModifiedDur],
            [SpreadDur],
            [OAS],
            [Convexity],
            [AdjustedDur],
            [YTM],
            [FIGI],
            [SYMBOL],
            [CUSIP],
            [ISIN],
            [SEDOL],
            [CreatedBy],
            [CreatedDate],
            [UpdatedBy],
            [UpdatedDate],
            [UnPivotValue],
            [Metric]
        )
        SELECT
            [SecurityAnalyticsUnpivotKey],
            [SecurityKey],
            [LinkAssetClassKey],
            [LinkSecurityTypeKey],
            [CurrencyKey],
            [CountryKey],
            [ShortName],
            [LongName],
            [SecurityDescription],
            [SourceSystemKey],
            [IndustryGICS],
            [SubindustryGICS],
            [SectorGICS],
            [IndustryGroupGICS],
            [SubSectorGICS],
            [EffectiveDt],
            [NextDividendPaydate],
            [LastDividendPaydate],
            [Factor],
            [OneMCPR],
            [ThreeMCPR],
            [SixMCPR],
            [TwelveMCPR],
            [DTC],
            [KeyRateDur6M],
            [KeyRateDur1Yr],
            [KeyRateDur2y],
            [KeyRateDur3y],
            [KeyRateDur5y],
            [KeyRateDur7y],
            [KeyRateDur10y],
            [WAC],
            [WAM],
            [ModifiedDur],
            [SpreadDur],
            [OAS],
            [Convexity],
            [AdjustedDur],
            [YTM],
            [FIGI],
            [SYMBOL],
            [CUSIP],
            [ISIN],
            [SEDOL],
            [CreatedBy],
            [CreatedDate],
            [UpdatedBy],
            [UpdatedDate],
            [UnPivotValue],
            [Metric]
        FROM [ims].[vw_RptSecurityAnalyticsUnpivot];

        SET @RowsInserted = @@ROWCOUNT;

        -----------------------------------------------------------------------
        -- Success Logging
        -----------------------------------------------------------------------
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        SET @ErrorMessage =
            ERROR_MESSAGE() + ' in RptSecurityAnalyticsUnpivot_Gold_Process';

        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

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
            -- Swallow logging errors so they never mask the real failure
        END CATCH

    END CATCH

END;

GO