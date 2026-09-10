CREATE TABLE [dbo].[Promotions] (
    [PromotionID]   INT            IDENTITY (1, 1) NOT NULL,
    [PromotionName] VARCHAR (100)  NOT NULL,
    [DiscountPct]   DECIMAL (5, 2) NOT NULL,
    [StartDate]     DATE           NOT NULL,
    [EndDate]       DATE           NOT NULL,
    PRIMARY KEY CLUSTERED ([PromotionID] ASC)
);


GO

