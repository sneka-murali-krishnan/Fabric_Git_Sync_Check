-- ============================== Source file: sp_Gold_Portfolio_Position_Table_300_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_Gold_Portfolio_Position_Table_300_Process]
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
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Portfolio Group
        -----------------------------------------------------------------------
        SET @TableName = 'DimPortfolioGroup'
        SET @ProcedureName = 'sp_DimPortfolioGroup'
        EXEC [ims].[sp_DimPortfolioGroup]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        -----------------------------------------------------------------------
        -- Portfolio
        -----------------------------------------------------------------------
        SET @TableName = 'DimPortfolio'
        SET @ProcedureName = 'sp_DimPortfolio'
        EXEC [ims].[sp_DimPortfolio]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        -----------------------------------------------------------------------
        -- Position
        -----------------------------------------------------------------------
        SET @TableName = 'DimPosition'
        SET @ProcedureName = 'sp_DimPosition'
        EXEC [ims].[sp_DimPosition]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

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

        SET @ErrorMessage =
            ERROR_MESSAGE();

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