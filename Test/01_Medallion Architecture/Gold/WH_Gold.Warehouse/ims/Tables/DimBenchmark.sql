CREATE TABLE [ims].[DimBenchmark] (
    [BenchmarkKey]  BIGINT          NULL,
    [BenchmarkCode] VARCHAR (8000)  NULL,
    [BenchmarkName] VARCHAR (8000)  NULL,
    [IndexCode]     VARCHAR (8000)  NULL,
    [IndexName]     VARCHAR (8000)  NULL,
    [MarketDate]    DATETIME2 (6)   NULL,
    [AvgMaturity]   DECIMAL (18, 4) NULL,
    [IsActive]      BIT             NULL,
    [IndexType]     VARCHAR (8000)  NULL,
    [CreatedBy]     VARCHAR (8000)  NULL,
    [CreatedDate]   DATETIME2 (6)   NULL,
    [UpdatedBy]     VARCHAR (8000)  NULL,
    [UpdatedDate]   DATETIME2 (6)   NULL,
    [BenchmarkId]   VARCHAR (8000)  NULL
);


GO