CREATE TABLE [Log].[ETLBatchGoldLogDetails] (
    [BatchId]           INT            NULL,
    [SchemaName]        VARCHAR (255)  NULL,
    [TableName]         VARCHAR (255)  NULL,
    [ProcessedRowCount] BIGINT         NULL,
    [StartTime]         DATETIME2 (6)  NULL,
    [EndTime]           DATETIME2 (6)  NULL,
    [Status]            VARCHAR (255)  NULL,
    [ErrorMessage]      VARCHAR (8000) NULL,
    [SourceName]        VARCHAR (255)  NULL
);


GO