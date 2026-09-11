CREATE TABLE [ims].[DimPortfolio] (
    [PortfolioKey]         BIGINT         NULL,
    [PortfolioId]          VARCHAR (8000) NULL,
    [PortfolioCode]        VARCHAR (8000) NULL,
    [ShortName]            VARCHAR (8000) NULL,
    [LongName]             VARCHAR (8000) NULL,
    [PortfolioDescription] VARCHAR (8000) NULL,
    [ParentId]             INT            NULL,
    [InceptionDate]        DATETIME2 (6)  NULL,
    [TerminationDate]      DATETIME2 (6)  NULL,
    [PortfolioType]        VARCHAR (8000) NULL,
    [IsActive]             BIT            NULL,
    [PortfolioGroupCode]   VARCHAR (8000) NULL,
    [PortfolioGroupName]   VARCHAR (8000) NULL,
    [StrategyKey]          BIGINT         NULL,
    [BenchmarkKey]         BIGINT         NULL,
    [CustodianKey]         BIGINT         NULL,
    [CreatedBy]            VARCHAR (8000) NULL,
    [CreatedDate]          DATETIME2 (6)  NULL,
    [UpdatedBy]            VARCHAR (8000) NULL,
    [UpdatedDate]          DATETIME2 (6)  NULL
);


GO