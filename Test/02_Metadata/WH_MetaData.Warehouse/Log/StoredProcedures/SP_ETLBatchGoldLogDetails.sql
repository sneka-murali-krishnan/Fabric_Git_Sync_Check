CREATE PROCEDURE Log.SP_ETLBatchGoldLogDetails
                    @BatchId                INT,
                    @SchemaName             VARCHAR(255),
                    @TableName              VARCHAR(255),
                    @ProcessedRowCount      BIGINT          = NULL,
                    @StartTime              DATETIME2(6)    = NULL,
                    @EndTime                DATETIME2(6)    = NULL,
                    @Status                 VARCHAR(255)    = NULL,
                    @ErrorMessage           VARCHAR(8000)   = NULL,
                    @SourceName             VARCHAR(255)
                AS
                BEGIN
                    INSERT INTO Log.ETLBatchGoldLogDetails
                    (BatchId, SchemaName, TableName, ProcessedRowCount,
                     StartTime, EndTime, Status, ErrorMessage, SourceName)
                    VALUES
                    (@BatchId, @SchemaName, @TableName, @ProcessedRowCount,
                     @StartTime, @EndTime, @Status, @ErrorMessage, @SourceName);
                END

GO