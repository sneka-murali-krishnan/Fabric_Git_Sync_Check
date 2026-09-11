CREATE TABLE [ims].[RptPFStressTest] (
    [RPTPFKey]      BIGINT          NULL,
    [PortfolioCode] VARCHAR (8000)  NULL,
    [SecurityKey]   INT             NULL,
    [Identifier]    VARCHAR (8000)  NULL,
    [EffectiveDt]   DATE            NULL,
    [DateKey]       BIGINT          NULL,
    [Type]          VARCHAR (8000)  NULL,
    [Metric]        VARCHAR (8000)  NULL,
    [UnpivotValue]  DECIMAL (18, 4) NULL,
    [createdby]     VARCHAR (8000)  NULL,
    [createdat]     DATETIME2 (6)   NULL,
    [updatedby]     VARCHAR (8000)  NULL,
    [updateddate]   DATETIME2 (6)   NULL
);


GO