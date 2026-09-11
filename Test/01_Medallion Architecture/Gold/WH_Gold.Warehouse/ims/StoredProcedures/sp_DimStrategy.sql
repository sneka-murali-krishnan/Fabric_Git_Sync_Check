-- ============================== Source file: Strategy_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimStrategy]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'DimStrategy';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'Strategy_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.DimStrategy ----
        IF OBJECT_ID(N'ims.DimStrategy', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimStrategy does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimStrategy;

        SET @SQL = N'INSERT INTO ims.DimStrategy (
            StrategyKey,
            StrategyId,
            ParentId,
            Code,
            Name,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.StrategyKey,
            s.StrategyId,
            s.ParentId,
            s.Code,
            s.Name,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].Strategy s
        LEFT JOIN ims.DimStrategy d
            ON s.StrategyKey = d.StrategyKey;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.DimStrategyExt ----
        IF OBJECT_ID(N'ims.DimStrategyExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.DimStrategyExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.DimStrategyExt;

        SET @SQL = N'INSERT INTO ims.DimStrategyExt (
            StrategyKey
        )
        SELECT
            s.StrategyKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StrategyExt s
        LEFT JOIN ims.DimStrategyExt d ON s.StrategyKey = d.StrategyKey;';
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Strategy_Gold_Process';
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