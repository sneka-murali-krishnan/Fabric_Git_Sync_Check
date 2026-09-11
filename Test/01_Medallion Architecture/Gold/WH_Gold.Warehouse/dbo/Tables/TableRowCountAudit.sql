CREATE TABLE [dbo].[TableRowCountAudit] (
    [TableId]          BIGINT          NULL,
    [SchemaName]       VARCHAR (8000)  NULL,
    [TableName]        VARCHAR (8000)  NULL,
    [PrevRowCount]     INT             NULL,
    [CurRowCount]      INT             NULL,
    [PercentageChange] DECIMAL (19, 2) NULL,
    [LastSyncTime]     DATETIME2 (6)   NULL,
    [IsActive]         BIT             NULL
);


GO