-- ============================== Source file: sp_Gold_Reference_Table_100_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_Gold_Reference_Table_100_Process]
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
        -- DimSourceSystemType
        -----------------------------------------------------------------------
        SET @TableName = 'DimSourceSystemType';
        SET @ProcedureName = 'sp_DimSourceSystemType';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimSourceSystemType]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimSourceSystem
        -----------------------------------------------------------------------
        SET @TableName = 'DimSourceSystem';
        SET @ProcedureName = 'sp_DimSourceSystem';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimSourceSystem]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimSecurityType
        -----------------------------------------------------------------------
        SET @TableName = 'DimSecurityType';
        SET @ProcedureName = 'sp_DimSecurityType';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimSecurityType]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimAggregation
        -----------------------------------------------------------------------
        SET @TableName = 'DimAggregation';
        SET @ProcedureName = 'sp_DimAggregation';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimAggregation]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimAggregationMetric
        -----------------------------------------------------------------------
        SET @TableName = 'DimAggregationMetric';
        SET @ProcedureName = 'sp_DimAggregationMetric';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimAggregationMetric]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimAssetClass
        -----------------------------------------------------------------------
        SET @TableName = 'DimAssetClass';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimAssetClass]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimBroker
        -----------------------------------------------------------------------
        SET @TableName = 'DimBroker';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimBroker]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimClient
        -----------------------------------------------------------------------
        SET @TableName = 'DimClient';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimClient]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimCountry
        -----------------------------------------------------------------------
        SET @TableName = 'DimCountry';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimCountry]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimCurrency
        -----------------------------------------------------------------------
        SET @TableName = 'DimCurrency';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimCurrency]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimCustodian
        -----------------------------------------------------------------------
        SET @TableName = 'DimCustodian';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimCustodian]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimGics
        -----------------------------------------------------------------------
        SET @TableName = 'DimGics';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimGics]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimMetric
        -----------------------------------------------------------------------
        SET @TableName = 'DimMetric';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimMetric]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        -----------------------------------------------------------------------
        -- DimStrategy
        -----------------------------------------------------------------------
        SET @TableName = 'DimStrategy';
        SET @StartTime = SYSUTCDATETIME();

        EXEC [ims].[sp_DimStrategy]
            @SilverLakehouse = @SilverLakehouse,
            @BatchId = @BatchId;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
            + ' Seconds';

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