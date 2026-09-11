CREATE TABLE [ims].[FactPosition] (
    [PositionKey]           BIGINT          NULL,
    [AsofDate]              DATETIME2 (6)   NULL,
    [PortfolioCode]         VARCHAR (8000)  NULL,
    [Identifier]            VARCHAR (8000)  NULL,
    [MarketPrice]           DECIMAL (18, 4) NULL,
    [MarketValue]           DECIMAL (18, 4) NULL,
    [OriginalFace]          DECIMAL (18, 4) NULL,
    [CurrentFace]           DECIMAL (18, 4) NULL,
    [Quantity]              DECIMAL (18, 4) NULL,
    [Factor]                INT             NULL,
    [AccruedInterestAmount] DECIMAL (18, 4) NULL,
    [NotionalValue]         DECIMAL (18, 4) NULL,
    [Coupon]                DECIMAL (18, 4) NULL,
    [TicketId]              VARCHAR (8000)  NULL,
    [DateKey]               BIGINT          NULL,
    [SecurityKey]           BIGINT          NULL,
    [PortfolioKey]          BIGINT          NULL,
    [CreatedBy]             VARCHAR (8000)  NULL,
    [CreatedDate]           DATETIME2 (6)   NULL,
    [UpdatedBy]             VARCHAR (8000)  NULL,
    [UpdatedDate]           DATETIME2 (6)   NULL
);


GO