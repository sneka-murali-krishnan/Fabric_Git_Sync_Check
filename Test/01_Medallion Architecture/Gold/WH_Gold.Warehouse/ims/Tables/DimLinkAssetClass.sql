CREATE TABLE [ims].[DimLinkAssetClass] (
    [LinkAssetClassKey]            BIGINT         NULL,
    [AssetClassCode]               VARCHAR (8000) NULL,
    [AssetClassName]               VARCHAR (8000) NULL,
    [ParentAssetClassCode]         VARCHAR (8000) NULL,
    [ParentAssetClassName]         VARCHAR (8000) NULL,
    [CustomerAssetClassCode]       VARCHAR (8000) NULL,
    [CustomerAssetClassName]       VARCHAR (8000) NULL,
    [ParentCustomerAssetClassCode] VARCHAR (8000) NULL,
    [ParentCustomerAssetClassName] VARCHAR (8000) NULL,
    [CreatedBy]                    VARCHAR (8000) NULL,
    [CreatedDate]                  DATETIME2 (6)  NULL,
    [UpdatedBy]                    VARCHAR (8000) NULL,
    [UpdatedDate]                  DATETIME2 (6)  NULL
);


GO