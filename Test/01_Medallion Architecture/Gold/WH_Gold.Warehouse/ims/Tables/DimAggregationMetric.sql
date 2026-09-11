CREATE TABLE [ims].[DimAggregationMetric] (
    [AggregationMetricKey] BIGINT         NULL,
    [MetricCode]           VARCHAR (8000) NULL,
    [MetricName]           VARCHAR (8000) NULL,
    [MetricGroup]          VARCHAR (8000) NULL,
    [MetricDisplayName]    VARCHAR (8000) NULL,
    [MetricLabel]          VARCHAR (8000) NULL,
    [AggregationCode]      VARCHAR (8000) NULL,
    [AggregationName]      VARCHAR (8000) NULL,
    [AggregationType]      VARCHAR (8000) NULL,
    [SortOrder]            INT            NULL,
    [Formula]              VARCHAR (8000) NULL,
    [Source]               VARCHAR (8000) NULL,
    [CreatedBy]            VARCHAR (8000) NULL,
    [CreatedDate]          DATETIME2 (6)  NULL,
    [UpdatedBy]            VARCHAR (8000) NULL,
    [UpdatedDate]          DATETIME2 (6)  NULL
);


GO