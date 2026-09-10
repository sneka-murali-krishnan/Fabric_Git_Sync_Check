CREATE TABLE [dbo].[Shipments] (
    [ShipmentID]   INT  IDENTITY (1, 1) NOT NULL,
    [OrderID]      INT  NOT NULL,
    [CarrierID]    INT  NOT NULL,
    [ShipDate]     DATE NOT NULL,
    [DeliveryDate] DATE NOT NULL,
    PRIMARY KEY CLUSTERED ([ShipmentID] ASC),
    FOREIGN KEY ([CarrierID]) REFERENCES [dbo].[ShippingCarriers] ([CarrierID]),
    FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders] ([OrderID])
);


GO

