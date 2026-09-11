-- ============================== Source file: sp_RptPortfolioBenchmarkVariance_Gold.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptPortfolioBenchmarkVariance]
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptPortfolioBenchmarkVariance';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);
    DECLARE @RowsInserted INT = 0;

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Full Refresh
        -----------------------------------------------------------------------

        TRUNCATE TABLE [ims].[RptPortfolioBenchmarkVariance];

        INSERT INTO [ims].[RptPortfolioBenchmarkVariance]
        (
            [RptPortfolioVarianceKey],
            [StrategyCode],
            [StrategyName],
            [PortfolioKey],
            [PFBMCode],
            [PFBMType],
            [LinkedBenchmarkCode],
            [VariancePFBMCode],
            [Type],
            [PFBMName],
            [IsActive],
            [Root],
            [PFBMDisplayCode],
            [CreatedBy],
            [CreatedDate],
            [UpdatedBy],
            [UpdatedDate]
        )
        SELECT
            [RptPortfolioVarianceKey],
            [StrategyCode],
            [StrategyName],
            [PortfolioKey],
            [PFBMCode],
            [PFBMType],
            [LinkedBenchmarkCode],
            [VariancePFBMCode],
            [Type],
            [PFBMName],
            [IsActive],
            [Root],
            [PFBMDisplayCode],
            [CreatedBy],
            [CreatedDate],
            [UpdatedBy],
            [UpdatedDate]
        FROM [ims].[vw_RptPortfolioBenchmarkVariance];

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
                'sp_RptPortfolioBenchmarkVariance'
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
                'sp_RptPortfolioBenchmarkVariance'
            );

        END TRY
        BEGIN CATCH
            -- Swallow logging errors so they never mask the real failure
        END CATCH

    END CATCH

END;

GO