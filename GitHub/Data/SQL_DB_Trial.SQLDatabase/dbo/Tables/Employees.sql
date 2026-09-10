CREATE TABLE [dbo].[Employees] (
    [EmployeeID]   INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeName] VARCHAR (100) NOT NULL,
    [StoreID]      INT           NOT NULL,
    [HireDate]     DATE          NOT NULL,
    [Role]         VARCHAR (50)  NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID] ASC),
    FOREIGN KEY ([StoreID]) REFERENCES [dbo].[Stores] ([StoreID])
);


GO

