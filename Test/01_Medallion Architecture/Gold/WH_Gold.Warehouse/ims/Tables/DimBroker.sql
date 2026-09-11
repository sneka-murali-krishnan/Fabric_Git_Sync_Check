CREATE TABLE [ims].[DimBroker] (
    [BrokerKey]   BIGINT         NULL,
    [BrokerId]    VARCHAR (8000) NULL,
    [Code]        VARCHAR (8000) NULL,
    [Name]        VARCHAR (8000) NULL,
    [DTCCode]     VARCHAR (8000) NULL,
    [CreatedBy]   VARCHAR (8000) NULL,
    [CreatedDate] DATETIME2 (6)  NULL,
    [UpdatedBy]   VARCHAR (8000) NULL,
    [UpdatedDate] DATETIME2 (6)  NULL
);


GO