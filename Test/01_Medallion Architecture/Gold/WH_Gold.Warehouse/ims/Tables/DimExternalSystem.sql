CREATE TABLE [ims].[DimExternalSystem] (
    [ExternalSystemKey] BIGINT         NULL,
    [ExternalSystemId]  VARCHAR (8000) NULL,
    [Code]              VARCHAR (8000) NULL,
    [Name]              VARCHAR (8000) NULL,
    [CreatedBy]         VARCHAR (8000) NULL,
    [CreatedDate]       DATETIME2 (6)  NULL,
    [ModifiedBy]        VARCHAR (8000) NULL,
    [ModifiedDate]      DATETIME2 (6)  NULL
);


GO