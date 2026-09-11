CREATE TABLE [ims].[FactPortfolioStressTestResults] (
    [PFTestresultKey] BIGINT          NULL,
    [PortfolioCode]   VARCHAR (8000)  NULL,
    [EffectiveDate]   DATE            NULL,
    [DateKey]         BIGINT          NULL,
    [Scenario]        VARCHAR (8000)  NULL,
    [AllocationType]  VARCHAR (8000)  NULL,
    [ChangePercent]   DECIMAL (18, 4) NULL,
    [ChangeDollar]    DECIMAL (18, 4) NULL,
    [CreatedBy]       VARCHAR (8000)  NULL,
    [CreatedDate]     DATETIME2 (6)   NULL,
    [UpdatedBy]       VARCHAR (8000)  NULL,
    [UpdatedDate]     DATETIME2 (6)   NULL
);


GO