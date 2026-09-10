CREATE TABLE [dbo].[ShippingCarriers] (
    [CarrierID]   INT          IDENTITY (1, 1) NOT NULL,
    [CarrierName] VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([CarrierID] ASC)
);


GO

