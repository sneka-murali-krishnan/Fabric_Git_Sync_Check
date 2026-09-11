CREATE TABLE [ims].[DimIndexSecurity] (
    [IndexSecurityKey] BIGINT         NULL,
    [AsofDate]         DATETIME2 (6)  NULL,
    [Identifier]       VARCHAR (8000) NULL,
    [BenchmarkKey]     BIGINT         NULL,
    [SecurityKey]      BIGINT         NULL,
    [CurrentFace]      INT            NULL,
    [CreatedBy]        VARCHAR (8000) NULL,
    [CreatedDate]      DATETIME2 (6)  NULL,
    [UpdatedBy]        VARCHAR (8000) NULL,
    [UpdatedDate]      DATETIME2 (6)  NULL
);


GO