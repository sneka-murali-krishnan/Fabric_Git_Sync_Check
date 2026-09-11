-- ============================== Source file: Benchmark_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimBenchmark]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimBenchmark';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'Benchmark_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimBenchmark ----
        IF OBJECT_ID(N'ims.DimBenchmark', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimBenchmark does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimBenchmark;

        SET @SQL = N'INSERT INTO ims.DimBenchmark (
            BenchmarkId,
            BenchmarkKey,
            BenchmarkCode,
            BenchmarkName,
            IndexCode,
            IndexName,
            MarketDate,
            AvgMaturity,
            --YieldToMaturity,
            --AvgConvexity,
            --AvgCoupon,
            --CurrYield,
            IsActive,
            --ProviderCd,
            --ProxyBenchmarkCode,
            IndexType,
            --SourceSystemKey,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.BenchmarkId,
            s.BenchmarkKey,
            s.BenchmarkCode,
            s.BenchMarkName,
            s.IndexCode,
            s.IndexName,
            s.MarketDate,
            s.AvgMaturity,
            --s.YieldToMaturity,
            --s.AvgComvexity,
            --s.AvgCoupon,
            --s.CurrYield,
            cast(s.IsActive as bit),
            --s.ProviderCd,
            --s.ProxyBenchmarkCode,
            s.IndexType,
            --ss.SourceSystemKey,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Benchmark s
        LEFT JOIN ims.DimBenchmark d
            ON s.BenchmarkKey = d.BenchmarkKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimBenchmarkExt ----
        IF OBJECT_ID(N'ims.DimBenchmarkExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimBenchmarkExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimBenchmarkExt;

        SET @SQL = N'INSERT INTO ims.DimBenchmarkExt (
            BenchmarkKey
        )
        SELECT
            s.BenchmarkKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].BenchmarkExt s
        LEFT JOIN ims.DimBenchmarkExt d ON s.BenchmarkKey = d.BenchmarkKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Benchmark_Gold_Process';
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