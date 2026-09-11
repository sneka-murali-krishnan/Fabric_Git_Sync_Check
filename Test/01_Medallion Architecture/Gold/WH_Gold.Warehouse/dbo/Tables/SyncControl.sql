CREATE TABLE [dbo].[SyncControl] (
    [TableName]    VARCHAR (8000) NULL,
    [LastSyncTime] DATETIME2 (6)  NULL,
    [UpdatedDate]  DATETIME2 (6)  NULL
);


GO