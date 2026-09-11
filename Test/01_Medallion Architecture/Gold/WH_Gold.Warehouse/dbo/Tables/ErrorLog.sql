CREATE TABLE [dbo].[ErrorLog] (
    [ErrorDateTime] DATETIME2 (6)  NULL,
    [ErrorMessage]  VARCHAR (8000) NULL,
    [ErrorSeverity] INT            NULL,
    [ErrorState]    INT            NULL,
    [ProcedureName] VARCHAR (8000) NULL,
    [SessionID]     VARCHAR (8000) NULL,
    [PipelineId]    VARCHAR (8000) NULL,
    [LogLevel]      VARCHAR (8000) NULL
);


GO