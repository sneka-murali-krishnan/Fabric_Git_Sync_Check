CREATE TABLE [ims].[DimLinkSecurityType] (
    [LinkSecurityTypeKey]      BIGINT         NULL,
    [SecurityTypeCode]         VARCHAR (8000) NULL,
    [CustomerSecurityTypeCode] VARCHAR (8000) NULL,
    [SecurityTypeName]         VARCHAR (8000) NULL,
    [CustomerSecurityTypeName] VARCHAR (8000) NULL,
    [SecurityTypeKey]          BIGINT         NULL,
    [CustomerSecurityTypeKey]  BIGINT         NULL,
    [CreatedBy]                VARCHAR (8000) NULL,
    [CreatedDate]              DATETIME2 (6)  NULL,
    [UpdatedBy]                VARCHAR (8000) NULL,
    [UpdatedDate]              DATETIME2 (6)  NULL
);


GO