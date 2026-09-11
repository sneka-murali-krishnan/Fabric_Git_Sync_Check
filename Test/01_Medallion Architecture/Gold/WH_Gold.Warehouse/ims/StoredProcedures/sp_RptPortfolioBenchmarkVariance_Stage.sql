-- ============================== Source file: sp_RptPortfolioBenchmarkVariance_Stage.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptPortfolioBenchmarkVariance_Stage]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver', -- not used in this procedure
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'RptPortfolioBenchmarkVariance_Stage';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256) = 'RptPortfolioBenchmarkVariance_Stage_Gold_Process';
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
        IF OBJECT_ID(N'ims.RptPortfolioBenchmarkVariance_Stage', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.RptPortfolioBenchmarkVariance_Stage does not exist.', 1;
        END;

        -----------------------------------------------------------------------
        -- Full Refresh
        -----------------------------------------------------------------------
        TRUNCATE TABLE ims.RptPortfolioBenchmarkVariance_Stage;

        INSERT INTO ims.RptPortfolioBenchmarkVariance_Stage
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
            Final.[RptPortfolioVarianceKey],
            Final.[StrategyCode],
            Final.[StrategyName],
            Final.[PortfolioKey],
            Final.[PFBMCode],
            Final.[PFBMType],
            Final.[LinkedBenchmarkCode],
            Final.[VariancePFBMCode],
            Final.[Type],
            Final.[PFBMName],
            Final.[IsActive],
            Final.[Root],
            Final.[PFBMDisplayCode],
            Final.[CreatedBy],
            Final.[CreatedDate],
            Final.[UpdatedBy],
            Final.[UpdatedDate]
        FROM
        (
            SELECT
                ROW_NUMBER() OVER (
                    ORDER BY PFBMCode, VariancePFBMCode
                ) AS RptPortfolioVarianceKey,
                *
            FROM
            (
                SELECT
                    pb.StrategyCode AS StrategyCode,
                    pb.StrategyName AS StrategyName,
                    pb.PortfolioKey AS PortfolioKey,
                    pb.PFBMCode AS PFBMCode,
                    pb.PFBMType AS PFBMType,
                    pb.LinkedBenchmarkCode AS LinkedBenchmarkCode,
                    pbv.PFBMCode AS VariancePFBMCode,
                    '3-Variance' AS Type,
                    'Diff of ' + pb.PFBMCode + ' & ' + pbv.PFBMCode AS PFBMName,
                    NULL AS IsActive,
                    pb.Root AS Root,
                    '(' + pb.PFBMCode + ' - ' + pbv.PFBMCode + ')' AS PFBMDisplayCode,
                    pb.CreatedBy AS CreatedBy,
                    pb.CreatedDate AS CreatedDate,
                    pb.UpdatedBy AS UpdatedBy,
                    CASE
                        WHEN pb.UpdatedDate > pbv.UpdatedDate
                            THEN pb.UpdatedDate
                        ELSE pbv.UpdatedDate
                    END AS UpdatedDate
                FROM ims.RptPortfolioBenchmark_Stage pb
                CROSS JOIN ims.RptPortfolioBenchmark_Stage pbv
                WHERE
                    pb.PFBMName <> '1-Portfolio'
                    AND pb.PFBMCode <> pbv.PFBMCode

                UNION ALL

                SELECT
                    pb.StrategyCode,
                    pb.StrategyName,
                    pb.PortfolioKey,
                    pb.PFBMCode,
                    pb.PFBMType,
                    pb.LinkedBenchmarkCode,
                    pb.PFBMCode AS VariancePFBMCode,
                    pb.Type,
                    pb.PFBMName,
                    pb.IsActive,
                    pb.Root,
                    pb.PFBMCode AS PFBMDisplayCode,
                    pb.CreatedBy,
                    pb.CreatedDate,
                    pb.UpdatedBy,
                    pb.UpdatedDate
                FROM ims.RptPortfolioBenchmark_Stage pb
            ) X
        ) Final;

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
            ERROR_MESSAGE() + ' in RptPortfolioBenchmarkVariance_Stage_Gold_Process';

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