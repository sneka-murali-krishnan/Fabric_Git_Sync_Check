CREATE TABLE [gold].[DimCustomer] (
    [CustomerID]   INT           NOT NULL,
    [CustomerName] VARCHAR (100) NULL,
    [Email]        VARCHAR (150) NULL,
    [CountryName]  VARCHAR (100) NULL,
    [SignupDate]   DATE          NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);


GO

