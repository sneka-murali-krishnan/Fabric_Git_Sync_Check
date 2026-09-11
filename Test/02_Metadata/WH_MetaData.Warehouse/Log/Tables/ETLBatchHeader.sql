CREATE TABLE [Log].[ETLBatchHeader] (
    [BatchId]           INT           NOT NULL,
    [PipelineName]      VARCHAR (255) NULL,
    [PipelineRunId]     VARCHAR (255) NULL,
    [StartTime]         DATETIME2 (6) NULL,
    [EndTime]           DATETIME2 (6) NULL,
    [DurationInMinutes] INT           NULL,
    [Status]            VARCHAR (255) NULL,
    [ErrorMessage]      VARCHAR (600) NULL
);


GO