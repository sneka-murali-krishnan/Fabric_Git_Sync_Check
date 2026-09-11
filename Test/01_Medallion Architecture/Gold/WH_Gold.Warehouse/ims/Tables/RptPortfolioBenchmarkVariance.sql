CREATE TABLE [ims].[RptPortfolioBenchmarkVariance] (
    [RptPortfolioVarianceKey] INT            NULL,
    [StrategyCode]            VARCHAR (8000) NULL,
    [StrategyName]            VARCHAR (8000) NULL,
    [PortfolioKey]            BIGINT         NULL,
    [PFBMCode]                VARCHAR (8000) NULL,
    [PFBMType]                VARCHAR (8000) NULL,
    [LinkedBenchmarkCode]     VARCHAR (8000) NULL,
    [VariancePFBMCode]        VARCHAR (8000) NULL,
    [Type]                    VARCHAR (8000) NULL,
    [PFBMName]                VARCHAR (8000) NULL,
    [IsActive]                BIT            NULL,
    [Root]                    VARCHAR (8000) NULL,
    [PFBMDisplayCode]         VARCHAR (8000) NULL,
    [CreatedBy]               VARCHAR (8000) NULL,
    [CreatedDate]             DATETIME2 (6)  NULL,
    [UpdatedBy]               VARCHAR (8000) NULL,
    [UpdatedDate]             DATETIME2 (6)  NULL
);


GO