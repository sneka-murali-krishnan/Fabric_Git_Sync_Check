CREATE TABLE [dbo].[PositionRaw] (
    [AsOfDate]              VARCHAR (8000) NULL,
    [PortfolioCode]         VARCHAR (8000) NULL,
    [Identifier]            VARCHAR (8000) NULL,
    [MarketPrice]           INT            NULL,
    [MarketValue]           INT            NULL,
    [Originalface]          INT            NULL,
    [Currentface]           INT            NULL,
    [Quantity]              INT            NULL,
    [Factor]                INT            NULL,
    [AccruedInterestAmount] INT            NULL,
    [NationalValue]         INT            NULL,
    [Coupon]                INT            NULL,
    [TicketId]              INT            NULL
);


GO