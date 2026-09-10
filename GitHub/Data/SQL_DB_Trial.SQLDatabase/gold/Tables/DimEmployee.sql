CREATE TABLE [gold].[DimEmployee] (
    [EmployeeID]   INT           NOT NULL,
    [EmployeeName] VARCHAR (100) NULL,
    [Role]         VARCHAR (50)  NULL,
    [StoreID]      INT           NULL,
    [HireDate]     DATE          NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID] ASC)
);


GO

