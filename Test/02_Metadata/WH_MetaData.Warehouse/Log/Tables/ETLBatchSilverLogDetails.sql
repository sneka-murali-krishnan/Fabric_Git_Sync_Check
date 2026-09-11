CREATE TABLE [Log].[ETLBatchSilverLogDetails] (
    [BatchId]         VARCHAR (MAX) NULL,
    [TableId]         VARCHAR (MAX) NULL,
    [SchemaName]      VARCHAR (MAX) NULL,
    [TableName]       VARCHAR (MAX) NULL,
    [StartTime]       VARCHAR (MAX) NULL,
    [EndTime]         VARCHAR (MAX) NULL,
    [DurationInSec]   VARCHAR (MAX) NULL,
    [BronzeDataRead]  VARCHAR (MAX) NULL,
    [DataTypeCasting] VARCHAR (MAX) NULL,
    [BronzeCount]     VARCHAR (MAX) NULL,
    [SilverCount]     VARCHAR (MAX) NULL,
    [SourceDelete]    VARCHAR (MAX) NULL,
    [SilverDataLoad]  VARCHAR (MAX) NULL,
    [ErrorMessage]    VARCHAR (MAX) NULL,
    [Status]          VARCHAR (MAX) NULL,
    [EtlLoadedBy]     VARCHAR (MAX) NULL,
    [TargetTableName] VARCHAR (MAX) NULL
);


GO