-- ============================== Source file: sp_DimAccountPortfolio.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimAccountPortfolio]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimAccountPortfolio';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'AccountPortfolio_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimAccountPortfolio ----
        IF OBJECT_ID(N'ims.DimAccountPortfolio', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimAccountPortfolio does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimAccountPortfolio;

        SET @SQL = N'INSERT INTO ims.DimAccountPortfolio (
            PFACKey,
            PFACId,
            Code,
            AccountKey,
            AccountId,
            PortfolioKey,
            PortfolioId,
            PlanKey,
            IsActive,
            CreatedBy,
            CreatedDate,
            ModifiedBy,
            ModifiedDate
        )
        SELECT
            ap.PFACKey,
            ap.PFACId,
            ap.Code,
            ap.AccountKey,
            ap.AccountId,
            ap.PortfolioKey,
            ap.PortfolioId,
            ap.PlanKey,
            ap.IsActive,
            CURRENT_USER,
            FORMAT(GETDATE(), ''yyyy-MM-dd HH:mm:ss''),
            CURRENT_USER,
            FORMAT(GETDATE(), ''yyyy-MM-dd HH:mm:ss'')
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].AccountPortfolio ap
        LEFT JOIN ims.DimAccountPortfolio dap
            ON ap.PFACKey COLLATE Latin1_General_CI_AS = dap.PFACKey COLLATE Latin1_General_CI_AS
        WHERE dap.PFACKey IS NULL;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in AccountPortfolio_Gold_Process';
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