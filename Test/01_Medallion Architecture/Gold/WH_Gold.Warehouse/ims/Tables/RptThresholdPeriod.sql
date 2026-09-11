CREATE TABLE [ims].[RptThresholdPeriod] (
    [MVPeriod]                        INT            NULL,
    [PFBMCode]                        VARCHAR (8000) NULL,
    [PFBMType]                        VARCHAR (8000) NULL,
    [MVDuration]                      INT            NULL,
    [MVStartDate]                     DATETIME2 (6)  NULL,
    [MVEndDate]                       DATETIME2 (6)  NULL,
    [MVDateRange]                     VARCHAR (8000) NULL,
    [MVDateRangeFuture6Months]        VARCHAR (8000) NULL,
    [MVPercentageChange]              FLOAT (53)     NULL,
    [MVPercentageChangeFuture6Months] FLOAT (53)     NULL,
    [BMIsRising]                      INT            NULL
);


GO