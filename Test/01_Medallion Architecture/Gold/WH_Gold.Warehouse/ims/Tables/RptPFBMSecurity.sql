CREATE TABLE [ims].[RptPFBMSecurity] (
    [RptPFBMKey]  INT             NULL,
    [PFBMCode]    VARCHAR (8000)  NULL,
    [AsOfDate]    DATETIME2 (6)   NULL,
    [SecurityKey] BIGINT          NULL,
    [Quantity]    DECIMAL (18, 4) NULL,
    [IsPortfolio] BIT             NULL,
    [CreatedBy]   VARCHAR (8000)  NULL,
    [CreatedDate] DATETIME2 (6)   NULL,
    [UpdatedBy]   VARCHAR (8000)  NULL,
    [UpdatedDate] DATETIME2 (6)   NULL
);


GO