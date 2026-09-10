CREATE TABLE [gold].[DimStore] (
    [StoreID]     INT           NOT NULL,
    [StoreName]   VARCHAR (100) NULL,
    [RegionName]  VARCHAR (100) NULL,
    [CountryName] VARCHAR (100) NULL,
    [OpenDate]    DATE          NULL,
    PRIMARY KEY CLUSTERED ([StoreID] ASC)
);


GO

