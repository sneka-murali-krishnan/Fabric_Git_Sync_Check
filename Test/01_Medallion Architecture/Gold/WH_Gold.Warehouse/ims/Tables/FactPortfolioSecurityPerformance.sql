CREATE TABLE [ims].[FactPortfolioSecurityPerformance] (
    [PerformanceKey]  BIGINT          NULL,
    [PortfolioCode]   VARCHAR (8000)  NULL,
    [Identifier]      VARCHAR (8000)  NULL,
    [SecurityKey]     BIGINT          NULL,
    [PerformanceDate] DATE            NULL,
    [Return_1Day]     DECIMAL (18, 4) NULL,
    [Return_1Week]    DECIMAL (18, 4) NULL,
    [Return_1Month]   DECIMAL (18, 4) NULL,
    [Return_3Months]  DECIMAL (18, 4) NULL,
    [Return_6Months]  DECIMAL (18, 4) NULL,
    [Return_1Year]    DECIMAL (18, 4) NULL,
    [Return_2Years]   DECIMAL (18, 4) NULL,
    [Return_3Years]   DECIMAL (18, 4) NULL,
    [Return_5Years]   DECIMAL (18, 4) NULL,
    [Return_7Years]   DECIMAL (18, 4) NULL,
    [Return_MTD]      DECIMAL (18, 4) NULL,
    [Return_QTD]      DECIMAL (18, 4) NULL,
    [Return_YTD]      DECIMAL (18, 4) NULL,
    [CreatedDate]     DATETIME2 (6)   NULL,
    [CreatedBy]       VARCHAR (8000)  NULL,
    [UpdatedDate]     DATETIME2 (6)   NULL,
    [UpdatedBy]       VARCHAR (8000)  NULL
);


GO