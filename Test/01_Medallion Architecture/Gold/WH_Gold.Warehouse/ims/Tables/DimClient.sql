CREATE TABLE [ims].[DimClient] (
    [ClientKey]            BIGINT         NULL,
    [ClientId]             VARCHAR (8000) NULL,
    [Code]                 VARCHAR (8000) NULL,
    [Name]                 VARCHAR (8000) NULL,
    [ShortName]            VARCHAR (8000) NULL,
    [LongName]             VARCHAR (8000) NULL,
    [CreatedBy]            VARCHAR (8000) NULL,
    [CreatedDate]          DATETIME2 (6)  NULL,
    [UpdatedBy]            VARCHAR (8000) NULL,
    [UpdatedDate]          DATETIME2 (6)  NULL,
    [ExternalSystemKey]    BIGINT         NULL,
    [ExternalSystemClient] BIGINT         NULL
);


GO