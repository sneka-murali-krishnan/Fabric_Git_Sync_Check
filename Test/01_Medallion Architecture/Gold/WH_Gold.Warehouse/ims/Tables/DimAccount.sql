CREATE TABLE [ims].[DimAccount] (
    [AccountKey]                  BIGINT         NULL,
    [AccountId]                   VARCHAR (8000) NULL,
    [Code]                        VARCHAR (8000) NULL,
    [Name]                        VARCHAR (8000) NULL,
    [ExternalSystemKey]           BIGINT         NULL,
    [ExternalSystemAccountNumber] VARCHAR (8000) NULL,
    [PlanKey]                     BIGINT         NULL,
    [InceptionDate]               DATE           NULL,
    [IsActive]                    BIT            NULL,
    [TerminationDate]             DATE           NULL,
    [CountryKey]                  BIGINT         NULL,
    [CurrencyKey]                 BIGINT         NULL,
    [CreatedBy]                   VARCHAR (8000) NULL,
    [CreatedDate]                 DATETIME2 (6)  NULL,
    [ModifiedBy]                  VARCHAR (8000) NULL,
    [ModifiedDate]                DATETIME2 (6)  NULL,
    [ClientKey]                   BIGINT         NULL
);


GO