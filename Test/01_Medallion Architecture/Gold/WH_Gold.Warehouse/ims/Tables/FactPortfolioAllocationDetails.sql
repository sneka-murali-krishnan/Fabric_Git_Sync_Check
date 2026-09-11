CREATE TABLE [ims].[FactPortfolioAllocationDetails] (
    [PFAllocationKey]      BIGINT          NULL,
    [PortfolioCode]        VARCHAR (8000)  NULL,
    [EffectiveDate]        DATE            NULL,
    [DateKey]              BIGINT          NULL,
    [AllocationType]       VARCHAR (8000)  NULL,
    [Ticker]               VARCHAR (8000)  NULL,
    [AllocationPercentage] DECIMAL (18, 4) NULL,
    [Quantity]             DECIMAL (18, 4) NULL,
    [CreatedBy]            VARCHAR (8000)  NULL,
    [CreatedDate]          DATETIME2 (6)   NULL,
    [UpdatedBy]            VARCHAR (8000)  NULL,
    [UpdatedDate]          DATETIME2 (6)   NULL
);


GO