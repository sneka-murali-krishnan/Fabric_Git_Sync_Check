CREATE TABLE [dbo].[Customers] (
    [CustomerID]   INT           IDENTITY (1, 1) NOT NULL,
    [CustomerName] VARCHAR (100) NOT NULL,
    [Email]        VARCHAR (150) NOT NULL,
    [CountryID]    INT           NOT NULL,
    [SignupDate]   DATE          NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Countries] ([CountryID])
);


GO

