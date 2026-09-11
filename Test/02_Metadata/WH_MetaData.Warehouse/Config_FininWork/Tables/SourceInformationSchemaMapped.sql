CREATE TABLE [Config_FininWork].[SourceInformationSchemaMapped] (
    [Id]                BIGINT        IDENTITY NOT NULL,
    [JobId]             VARCHAR (64)  NULL,
    [SourceTableSchema] VARCHAR (255) NULL,
    [SourceTableName]   VARCHAR (255) NULL,
    [SourceColumnName]  VARCHAR (255) NULL,
    [SourceDataType]    VARCHAR (128) NULL,
    [TargetTableName]   VARCHAR (255) NULL,
    [TargetColumnName]  VARCHAR (255) NULL,
    [TargetDataType]    VARCHAR (128) NULL,
    [IsExtension]       BIT           NULL,
    [IsPrimaryKey]      BIT           NULL,
    [MappingStatus]     VARCHAR (32)  NULL,
    [MappingScore]      FLOAT (53)    NULL,
    [MappingReason]     VARCHAR (500) NULL,
    [CreatedAt]         DATETIME2 (6) NULL
);


GO