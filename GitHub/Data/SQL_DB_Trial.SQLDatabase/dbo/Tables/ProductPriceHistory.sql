CREATE TABLE [dbo].[ProductPriceHistory] (
    [PriceHistoryID] INT             IDENTITY (1, 1) NOT NULL,
    [ProductID]      INT             NOT NULL,
    [OldPrice]       DECIMAL (10, 2) NOT NULL,
    [NewPrice]       DECIMAL (10, 2) NOT NULL,
    [ChangeDate]     DATE            NOT NULL,
    PRIMARY KEY CLUSTERED ([PriceHistoryID] ASC),
    FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);


GO

