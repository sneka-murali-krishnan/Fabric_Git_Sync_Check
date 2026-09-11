CREATE TABLE [Config_FininWork].[IncrementalConfigETL] (
    [Id]                    BIGINT        NULL,
    [SourceSchemaName]      VARCHAR (MAX) NULL,
    [SourceTableName]       VARCHAR (MAX) NULL,
    [BronzeSchemaName]      VARCHAR (MAX) NULL,
    [BronzeTableName]       VARCHAR (MAX) NULL,
    [SilverSchemaName]      VARCHAR (MAX) NULL,
    [SilverTableName]       VARCHAR (MAX) NULL,
    [LoadType]              VARCHAR (MAX) NULL,
    [PrimaryKey]            VARCHAR (MAX) NULL,
    [IsFullLoad]            INT           NULL,
    [IncLoadType]           INT           NULL,
    [SourceQuery]           VARCHAR (MAX) NULL,
    [IsSourceDelete]        INT           NULL,
    [SourceDeleteQuery]     VARCHAR (MAX) NULL,
    [CreatedWaterMarkField] VARCHAR (MAX) NULL,
    [CreatedWaterMarkValue] DATETIME2 (6) NULL,
    [UpdatedWaterMarkField] VARCHAR (MAX) NULL,
    [UpdatedWaterMarkValue] DATETIME2 (6) NULL,
    [LastModifiedDate]      DATETIME2 (6) NULL,
    [LastModifiedBy]        VARCHAR (MAX) NULL,
    [IsActive]              INT           NULL
);


GO