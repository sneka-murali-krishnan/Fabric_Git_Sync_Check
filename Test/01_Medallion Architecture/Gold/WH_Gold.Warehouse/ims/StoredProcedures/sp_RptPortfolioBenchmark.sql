-- ============================== Source file: sp_RptPortfolioBenchmark.sql ==============================
CREATE   PROCEDURE [ims].[sp_RptPortfolioBenchmark]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver' -- not used in this procedure; source is a Gold-layer view, kept for signature consistency
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'RptPortfolioBenchmark';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'RptPortfolioBenchmark_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;

    BEGIN TRY

        -- ---- Target: ims.RptPortfolioBenchmark ----
        IF OBJECT_ID(N'ims.RptPortfolioBenchmark', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.RptPortfolioBenchmark does not exist.', 1;
        END

        TRUNCATE TABLE ims.RptPortfolioBenchmark;

        INSERT INTO ims.RptPortfolioBenchmark (
             [RptPortfolioKey]
            ,[StrategyCode]
            ,[StrategyName]
            ,[PortfolioKey]
            ,[PFBMCode]
            ,[PFBMType]
            ,[PFBMName]
            ,[Type]
            ,[IsActive]
            ,[Root]
            ,[LinkedBenchmarkCode]
            ,[CreatedBy]
            ,[CreatedDate]
            ,[UpdatedBy]
            ,[UpdatedDate]
        )
        SELECT
            s.RptPortfolioKey,
            s.StrategyCode,
            s.StrategyName,
            s.PortfolioKey,
            s.PFBMCode,
            s.PFBMType,
            s.PFBMName,
            s.Type,
            s.IsActive,
            s.Root,
            s.LinkedBenchmarkCode,
            s.[CreatedBy],
            s.[CreatedDate],
            s.[UpdatedBy],
            s.[UpdatedDate]
        FROM [ims].[vw_RptPortfolioBenchmark] s
        LEFT JOIN ims.RptPortfolioBenchmark d
            ON s.RptPortfolioKey = d.RptPortfolioKey
        WHERE d.RptPortfolioKey IS NULL;
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
        SET @ErrorMessage = ERROR_MESSAGE();
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