-- ============================== Source file: sp_Gold_Report_Table_Process_Test.sql ==============================
CREATE   PROCEDURE [ims].[sp_Gold_Report_Table_Process_Test]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver',
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200);
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256);
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6);
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);

    BEGIN TRY

        -----------------------------------------------------------------------
        -- RptPFBMSecurity
        -----------------------------------------------------------------------
        SET @TableName = 'RptPFBMSecurity';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptPFBMSecurity]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- RptPortfolioBenchmark
        -----------------------------------------------------------------------
        SET @TableName = 'RptPortfolioBenchmark';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptPortfolioBenchmark]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- RptPortfolioBenchmarkVariance
        -----------------------------------------------------------------------
        SET @TableName = 'RptPortfolioBenchmarkVariance';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptPortfolioBenchmarkVariance]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- RptSecurityAnalytics
        -----------------------------------------------------------------------
        SET @TableName = 'RptSecurityAnalytics';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptSecurityAnalytics]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- RptSecurityAnalyticsUnpivot
        -----------------------------------------------------------------------
        SET @TableName = 'RptSecurityAnalyticsUnpivot';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptSecurityAnalyticsUnpivot]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- RptPosAnalytics
        -----------------------------------------------------------------------
        SET @TableName = 'RptPosAnalytics';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptPosAnalytics]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

        -----------------------------------------------------------------------
        -- RptPosAnalyticsData
        -----------------------------------------------------------------------
        SET @TableName = 'RptPosAnalyticsData';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_RptPosAnalyticsData]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20)) + ' Seconds';

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

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(
                DATEDIFF(
                    SECOND,
                    ISNULL(@StartTime, @EndTime),
                    @EndTime
                ) AS VARCHAR(20)
            ) + ' Seconds';

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
            -- Swallow logging errors
        END CATCH

    END CATCH

END;

GO