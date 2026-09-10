CREATE TABLE [dbo].[Stores] (
    [StoreID]   INT           IDENTITY (1, 1) NOT NULL,
    [StoreName] VARCHAR (100) NOT NULL,
    [RegionID]  INT           NOT NULL,
    [OpenDate]  DATE          NOT NULL,
    PRIMARY KEY CLUSTERED ([StoreID] ASC),
    FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Regions] ([RegionID])
);


GO

