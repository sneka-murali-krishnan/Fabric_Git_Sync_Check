CREATE TABLE [Config_FininWork].[OneTimeConfigETL] (
    [Id]               INT           NOT NULL,
    [SourceTableName]  VARCHAR (MAX) NULL,
    [SourceSchemaName] VARCHAR (MAX) NULL,
    [BronzeSchemaName] VARCHAR (MAX) NULL,
    [BronzeTableName]  VARCHAR (MAX) NULL,
    [SilverSchemaName] VARCHAR (MAX) NULL,
    [SilverTableName]  VARCHAR (MAX) NULL,
    [SourceQuery]      VARCHAR (MAX) NULL,
    [IsActive]         VARCHAR (MAX) NOT NULL,
    [LoadType]         VARCHAR (MAX) NOT NULL,
    [PrimaryKey]       VARCHAR (MAX) NULL,
    [CreatedBy]        VARCHAR (MAX) NOT NULL,
    [CreatedDate]      VARCHAR (MAX) NOT NULL
);


GO