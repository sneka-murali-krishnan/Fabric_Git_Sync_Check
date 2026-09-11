CREATE TABLE [ims].[FactAccountPortfolio] (
    [PortfolioAccountKey] BIGINT         NULL,
    [PortfolioAccountId]  VARCHAR (8000) NULL,
    [Code]                VARCHAR (8000) NULL,
    [AccountKey]          BIGINT         NULL,
    [PortfolioKey]        BIGINT         NULL,
    [PlanKey]             BIGINT         NULL,
    [IsActive]            BIT            NULL,
    [CreatedBy]           VARCHAR (8000) NULL,
    [CreatedDate]         DATETIME2 (6)  NULL,
    [ModifiedBy]          VARCHAR (8000) NULL,
    [ModifiedDate]        DATETIME2 (6)  NULL
);


GO