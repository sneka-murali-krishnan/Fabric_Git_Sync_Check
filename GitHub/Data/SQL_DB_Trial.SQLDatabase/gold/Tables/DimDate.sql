CREATE TABLE [gold].[DimDate] (
    [DateKey]   INT          NOT NULL,
    [FullDate]  DATE         NOT NULL,
    [Year]      INT          NOT NULL,
    [Month]     INT          NOT NULL,
    [MonthName] VARCHAR (20) NOT NULL,
    [Quarter]   INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


GO

