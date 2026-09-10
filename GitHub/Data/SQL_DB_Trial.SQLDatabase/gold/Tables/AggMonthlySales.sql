CREATE TABLE [gold].[AggMonthlySales] (
    [RegionName]   VARCHAR (100)   NOT NULL,
    [SalesMonth]   DATE            NOT NULL,
    [MonthlySales] DECIMAL (14, 2) NULL,
    PRIMARY KEY CLUSTERED ([RegionName] ASC, [SalesMonth] ASC)
);


GO

