-- ============================== Source file: Portfolio_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimPortfolio]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimPortfolio';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'Portfolio_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimPortfolio ----
        IF OBJECT_ID(N'ims.DimPortfolio', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimPortfolio does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimPortfolio;

        SET @SQL = N'INSERT INTO ims.DimPortfolio (
            PortfolioKey,
            PortfolioId,
            PortfolioCode,
            ShortName,
            LongName,
            PortfolioDescription,
            ParentId,
            InceptionDate,
            TerminationDate,
            PortfolioType,
            IsActive,
            PortfolioGroupCode,
            PortfolioGroupName,
            StrategyKey,
            BenchmarkKey,
            CustodianKey,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.PortfolioKey,
            s.PortfolioCode,
            s.PortfolioCode,
            s.ShortName,
            s.LongName,
            s.PortfolioDescription,
            s.ParentId,
            s.InceptionDate,
            s.TerminationDate,
            s.PortfolioType,
            s.IsActive,
            pg.Code,
            pg.Name,
            st.StrategyKey,
            b.BenchmarkKey,
            cu.CustodianKey,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Portfolio s
        LEFT JOIN ims.DimPortfolio d
            ON s.PortfolioKey = d.PortfolioKey
        LEFT JOIN ims.DimStrategy st
            ON st.Code  COLLATE Latin1_General_CI_AS = s.StrategyCode COLLATE Latin1_General_CI_AS
            OR s.StrategyCode IS NULL
        LEFT JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].PortfolioGroup pg
            ON pg.Code COLLATE Latin1_General_CI_AS = s.PortfolioGroupCode COLLATE Latin1_General_CI_AS
            OR s.PortfolioGroupCode IS NULL
        LEFT JOIN ims.DimBenchmark b
            ON b.BenchmarkCode COLLATE Latin1_General_CI_AS = s.PrimaryBenchmarkCode COLLATE Latin1_General_CI_AS
            OR s.PrimaryBenchmarkCode IS NULL
        LEFT JOIN ims.DimCustodian cu
            ON cu.Code COLLATE Latin1_General_CI_AS = s.CustodianCode COLLATE Latin1_General_CI_AS
            OR s.CustodianCode IS NULL;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimPortfolioExt ----
        IF OBJECT_ID(N'ims.DimPortfolioExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimPortfolioExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimPortfolioExt;

        SET @SQL = N'INSERT INTO ims.DimPortfolioExt (
            PortfolioKey
        )
        SELECT
            s.PortfolioKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].PortfolioExt s
        LEFT JOIN ims.DimPortfolioExt d ON s.PortfolioKey = d.PortfolioKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Portfolio_Gold_Process';
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