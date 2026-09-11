CREATE TABLE [ims].[DimPlan] (
    [PlanKey]                  BIGINT         NULL,
    [PlanId]                   VARCHAR (8000) NULL,
    [Code]                     VARCHAR (8000) NULL,
    [Name]                     VARCHAR (8000) NULL,
    [IsTaxable]                BIT            NULL,
    [PlanTypeKey]              BIGINT         NULL,
    [CustodianKey]             BIGINT         NULL,
    [ExternalSystemKey]        BIGINT         NULL,
    [ExternalSystemPlanNumber] BIGINT         NULL,
    [CreatedBy]                VARCHAR (8000) NULL,
    [CreatedDate]              DATETIME2 (6)  NULL,
    [ModifiedBy]               VARCHAR (8000) NULL,
    [ModifiedDate]             DATETIME2 (6)  NULL
);


GO