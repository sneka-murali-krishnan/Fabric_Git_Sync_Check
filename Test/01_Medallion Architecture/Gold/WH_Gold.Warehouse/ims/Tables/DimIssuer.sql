CREATE TABLE [ims].[DimIssuer] (
    [IssuerKey]        BIGINT         NULL,
    [IssuerId]         INT            NULL,
    [Code]             VARCHAR (8000) NULL,
    [Name]             VARCHAR (8000) NULL,
    [Description]      VARCHAR (8000) NULL,
    [CreatedBy]        VARCHAR (8000) NULL,
    [CreatedDate]      DATETIME2 (6)  NULL,
    [LastModifiedBy]   VARCHAR (8000) NULL,
    [LastModifiedDate] DATETIME2 (6)  NULL
);


GO