-- ============================== Source file: sp_Gold_Reference_Table_200_Customer_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_Gold_Reference_Table_200_Customer_Process]
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
    DECLARE @SQL NVARCHAR(MAX);

    BEGIN TRY

        -----------------------------------------------------------------------
        -- DimBroker
        -----------------------------------------------------------------------
        SET @TableName = 'DimBroker';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimBroker]
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
        -- DimClient
        -----------------------------------------------------------------------
        SET @TableName = 'DimClient';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimClient]
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
        -- DimCountry
        -----------------------------------------------------------------------
        SET @TableName = 'DimCountry';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimCountry]
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
        -- DimCurrency
        -----------------------------------------------------------------------
        SET @TableName = 'DimCurrency';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimCurrency]
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
        -- DimCustodian
        -----------------------------------------------------------------------
        SET @TableName = 'DimCustodian';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimCustodian]
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
        -- DimGics
        -----------------------------------------------------------------------
        SET @TableName = 'DimGics';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimGics]
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
        -- DimStrategy
        -----------------------------------------------------------------------
        SET @TableName = 'DimStrategy';
        SET @ProcedureName = 'sp_' + @TableName;
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimStrategy]
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
            CAST(DATEDIFF(SECOND, ISNULL(@StartTime,@EndTime), @EndTime) AS VARCHAR(20))
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
            -- Swallow logging errors
        END CATCH

    END CATCH

END;

GO