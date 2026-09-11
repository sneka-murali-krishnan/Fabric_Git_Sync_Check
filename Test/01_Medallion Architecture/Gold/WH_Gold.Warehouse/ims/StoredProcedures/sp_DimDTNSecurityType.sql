-- ============================== Source file: DTNSecurityType_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_DimDTNSecurityType]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName     VARCHAR(200)  = 'DimDTNSecurityType';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'DTNSecurityType_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);
    DECLARE @MaxID         BIGINT = 0;

    BEGIN TRY

        -- ---- Target: dbo.Staging_DTNSecurityType (intermediate staging table) ----
        IF OBJECT_ID(N'dbo.Staging_DTNSecurityType', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table dbo.Staging_DTNSecurityType does not exist.', 1;
        END

        TRUNCATE TABLE dbo.Staging_DTNSecurityType;

        SET @SQL = N'
        INSERT INTO Staging_DTNSecurityType (Id, ShortName, LongName, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
        SELECT
            Id,
            ShortName,
            LongName,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].dtnsecuritytype;';
        EXEC sp_executesql @SQL;

        -- ---- Target: dbo.DimDTNSecurityType ----
        IF OBJECT_ID(N'dbo.DimDTNSecurityType', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table dbo.DimDTNSecurityType does not exist.', 1;
        END

        TRUNCATE TABLE dbo.DimDTNSecurityType;

        -- Table was just truncated, so this always evaluates to 0; kept for clarity/future-proofing
        SELECT @MaxID = ISNULL(MAX([DTNSecurityTypeKey]), 0) FROM dbo.DimDTNSecurityType;

        INSERT INTO DimDTNSecurityType (DTNSecurityTypeKey, Id, ShortName, LongName, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
        SELECT
            @MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS DTNSecurityTypeKey,
            s.Id, s.ShortName, s.LongName, s.CreatedBy, s.CreatedDate, s.UpdatedBy, s.UpdatedDate
        FROM Staging_DTNSecurityType s;
        SET @RowsInserted += @@ROWCOUNT;

        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' Seconds';

        BEGIN TRY
            INSERT INTO [WH_MetaData].[Log].[ETLBatchGoldLogDetails]
            (
                BatchId,
                SchemaName,
                TableName,
                ProcessedRowCount,
                StartTime,
                EndTime,
                Status,
                ErrorMessage,
                SourceName
            )
            VALUES
            (
                @BatchId,
                @SchemaName,
                @TableName,
                @RowsInserted,
                @StartTime,
                @EndTime,
                'Success',
                NULL,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE() + ' in DTNSecurityType_Gold_Process';
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @EndTime = SYSUTCDATETIME();
        SET @Duration = CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' Seconds';

        BEGIN TRY
            INSERT INTO [WH_MetaData].[Log].[ETLBatchGoldLogDetails]
            (
                BatchId,
                SchemaName,
                TableName,
                ProcessedRowCount,
                StartTime,
                EndTime,
                Status,
                ErrorMessage,
                SourceName
            )
            VALUES
            (
                @BatchId,
                @SchemaName,
                @TableName,
                0,
                @StartTime,
                @EndTime,
                'Failed',
                @ErrorMessage,
                @ProcedureName
            );
        END TRY
        BEGIN CATCH
            -- swallow logging errors so they never mask the real failure
        END CATCH
    END CATCH
END

GO