CREATE TABLE [dbo].[Reviews] (
    [ReviewID]   INT     IDENTITY (1, 1) NOT NULL,
    [ProductID]  INT     NOT NULL,
    [CustomerID] INT     NOT NULL,
    [Rating]     TINYINT NOT NULL,
    [ReviewDate] DATE    NOT NULL,
    PRIMARY KEY CLUSTERED ([ReviewID] ASC),
    FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]),
    FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);


GO

