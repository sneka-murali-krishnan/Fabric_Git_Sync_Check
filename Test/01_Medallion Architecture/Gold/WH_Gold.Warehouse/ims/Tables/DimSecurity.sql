CREATE TABLE [ims].[DimSecurity] (
    [SecurityKey]         BIGINT          NULL,
    [LinkAssetClassKey]   BIGINT          NULL,
    [LinkSecurityTypeKey] BIGINT          NULL,
    [FIGI]                VARCHAR (8000)  NULL,
    [CurrencyKey]         BIGINT          NULL,
    [CountryKey]          BIGINT          NULL,
    [ShortName]           VARCHAR (8000)  NULL,
    [LongName]            VARCHAR (8000)  NULL,
    [SecurityDescription] VARCHAR (8000)  NULL,
    [SourceSystemKey]     BIGINT          NULL,
    [IndustryGICS]        VARCHAR (8000)  NULL,
    [SubindustryGICS]     VARCHAR (8000)  NULL,
    [SectorGICS]          VARCHAR (8000)  NULL,
    [IndustryGroupGICS]   VARCHAR (8000)  NULL,
    [SubSectorGICS]       VARCHAR (8000)  NULL,
    [LatestEffectiveDt]   DATE            NULL,
    [OrginationDt]        DATE            NULL,
    [Coupon]              DECIMAL (18, 4) NULL,
    [ContractSize]        VARCHAR (8000)  NULL,
    [TotalShares]         DECIMAL (18, 4) NULL,
    [MaturityDate]        DATE            NULL,
    [CreatedBy]           VARCHAR (8000)  NULL,
    [CreatedDate]         DATETIME2 (6)   NULL,
    [UpdatedBy]           VARCHAR (8000)  NULL,
    [UpdatedDate]         DATETIME2 (6)   NULL,
    [ProductType]         VARCHAR (8000)  NULL,
    [IssuerKey]           BIGINT          NULL
);


GO