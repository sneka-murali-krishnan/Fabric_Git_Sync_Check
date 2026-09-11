-- ============================== Source file: sp_Gold_Fixed_Income_Process.sql ==============================
CREATE   PROCEDURE ims.sp_Gold_Fixed_Income_Process 
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver', 
    @BatchId INT = NULL 
/* UB Technology Innovations. Unauthorized use or reproduction is prohibited. */
AS 
BEGIN 
    SET NOCOUNT ON; 

    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @TableName VARCHAR(200),
            @ProcedureName VARCHAR(256),
            @ErrorMessage VARCHAR(8000),
            @Operation VARCHAR(10) = 'READ',
            @ErrorSeverity INT,
            @ErrorState INT,
            @StartTime DATETIME2(6) = SYSUTCDATETIME(),
            @EndTime DATETIME2(6),
            @Duration VARCHAR(50);

    BEGIN TRY 
        -- DimSecurity Execution
        SET @TableName = 'DimSecurity'; 
        SET @ProcedureName = 'DimSecurity_Gold_Process'; 
        EXEC ims.sp_DimSecurity @SilverLakehouse = @SilverLakehouse, @BatchId = @BatchId; 

        -- RiskAnalytics Execution
        SET @TableName = 'RiskAnalytics'; 
        SET @ProcedureName = 'RiskAnalytics_Gold_Process'; 
        EXEC ims.sp_DimRiskAnalytics @SilverLakehouse = @SilverLakehouse, @BatchId = @BatchId; 

        -- DollarAnalytics Execution
        SET @TableName = 'DollarAnalytics'; 
        SET @ProcedureName = 'DollarAnalytics_Gold_Process'; 
        EXEC ims.sp_DollarAnalytics @SilverLakehouse = @SilverLakehouse, @BatchId = @BatchId; 

        -- StandardAnalytics Execution
        SET @TableName = 'StandardAnalytics'; 
        SET @ProcedureName = 'StandardAnalytics_Gold_Process'; 
        EXEC ims.sp_StandardAnalytics @SilverLakehouse = @SilverLakehouse, @BatchId = @BatchId; 

        -- Success Logging 
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
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures so they never mask a data step that already succeeded.
        END CATCH
    END TRY 

    BEGIN CATCH 
        -- Error Handling
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Gold_Fixed_Income_Process'; 
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
            -- Swallow logging errors so they never mask the real failure 
        END CATCH 
        
        -- Raise the error back to the orchestration layer
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH 
END;

GO