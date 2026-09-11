CREATE TABLE [ims].[FactStandardAnalytics] (
    [StandardAnalyticsKey]   BIGINT          NULL,
    [SecurityKey]            BIGINT          NULL,
    [EffectiveDt]            DATE            NULL,
    [StandardSourceKey]      BIGINT          NULL,
    [StandardSourceFieldKey] BIGINT          NULL,
    [Value]                  DECIMAL (18, 4) NULL,
    [CreatedBy]              VARCHAR (8000)  NULL,
    [CreatedDate]            DATETIME2 (6)   NULL,
    [UpdatedBy]              VARCHAR (8000)  NULL,
    [UpdatedDate]            DATETIME2 (6)   NULL
);


GO