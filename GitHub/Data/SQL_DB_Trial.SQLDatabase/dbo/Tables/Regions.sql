CREATE TABLE [dbo].[Regions] (
    [RegionID]   INT           IDENTITY (1, 1) NOT NULL,
    [RegionName] VARCHAR (100) NOT NULL,
    [CountryID]  INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([RegionID] ASC),
    FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Countries] ([CountryID])
);


GO

