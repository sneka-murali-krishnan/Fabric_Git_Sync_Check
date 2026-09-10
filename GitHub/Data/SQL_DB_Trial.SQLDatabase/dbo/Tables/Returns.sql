CREATE TABLE [dbo].[Returns] (
    [ReturnID]      INT             IDENTITY (1, 1) NOT NULL,
    [OrderDetailID] INT             NOT NULL,
    [ReturnDate]    DATE            NOT NULL,
    [Reason]        VARCHAR (200)   NOT NULL,
    [RefundAmount]  DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([ReturnID] ASC),
    FOREIGN KEY ([OrderDetailID]) REFERENCES [dbo].[OrderDetails] ([OrderDetailID])
);


GO

