CREATE TABLE [dbo].[Suppliers] (
    [SupplierID]   INT           IDENTITY (1, 1) NOT NULL,
    [SupplierName] VARCHAR (100) NOT NULL,
    [CountryID]    INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([SupplierID] ASC),
    FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Countries] ([CountryID])
);


GO

