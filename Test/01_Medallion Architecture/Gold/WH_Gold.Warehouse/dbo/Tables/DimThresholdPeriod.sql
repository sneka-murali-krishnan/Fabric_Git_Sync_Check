CREATE TABLE [dbo].[DimThresholdPeriod] (
    [MVPeriod]           INT            NULL,
    [BenchmarkCode]      VARCHAR (8000) NULL,
    [PortfolioCode]      VARCHAR (8000) NULL,
    [MVDuration]         INT            NULL,
    [MVStartDate]        DATE           NULL,
    [MVEndDate]          DATE           NULL,
    [BMPercentageChange] FLOAT (53)     NULL,
    [PFPercentageChange] FLOAT (53)     NULL
);


GO