CREATE PROCEDURE Log.SP_ETLBatchBronzeDetails
                    @BatchId                INT,
                    @TableName              VARCHAR(255),
                    @TableId                INT,
                    @SchemaName             VARCHAR(255),
                    @ExtractedRowCount      BIGINT          = NULL,
                    @StartTime              DATETIME2(6)    = NULL,
                    @EndTime                DATETIME2(6)    = NULL,
                    @Status                 VARCHAR(255)    = NULL,
                    @ErrorMessage           VARCHAR(8000)   = NULL,
                    @SourceName             VARCHAR(255)
                AS
                BEGIN
                    INSERT INTO Log.ETLBatchBronzeDetails
                    (BatchId, TableName, SchemaName, ExtractedRowCount,
                     StartTime, EndTime, Status, ErrorMessage, SourceName, TableId)
                    VALUES
                    (@BatchId, @TableName, @SchemaName, @ExtractedRowCount,
                     @StartTime, @EndTime, @Status, @ErrorMessage, @SourceName, @TableId);
                END

GO