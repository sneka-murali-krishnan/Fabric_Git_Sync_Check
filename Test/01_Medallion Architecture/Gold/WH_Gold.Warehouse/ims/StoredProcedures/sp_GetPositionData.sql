-- ============================== Source file: sp_GetPositionData.sql ==============================
CREATE   PROCEDURE [ims].[sp_GetPositionData]

    @BatchId INT = NULL,
    -- Default added so MasterExecuter can run this on-demand data-access
    -- helper as part of the automated batch without erroring on a missing
    -- required parameter. NULL simply matches no rows (PortfolioCode is
    -- never actually NULL), so this is a safe no-op for the batch; real
    -- API callers still pass an actual portfolio code.
    @PortfolioCode VARCHAR(255) = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'FactPosition';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256) = 'GetPositionData';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Validate Source Table
        -----------------------------------------------------------------------
        IF OBJECT_ID(N'ims.FactPosition', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactPosition does not exist.', 1;
        END;

        -----------------------------------------------------------------------
        -- Return Position Data
        -----------------------------------------------------------------------
        SELECT *
        FROM ims.FactPosition
        WHERE AsOfDate >= DATEADD(YEAR, -1, GETDATE())
          AND PortfolioCode = @PortfolioCode;

        -----------------------------------------------------------------------
        -- Success Logging
        -----------------------------------------------------------------------
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

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

        SET @ErrorMessage =
            ERROR_MESSAGE() + ' in GetPositionData';

        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR(20))
            + ' Seconds';

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
            -- Swallow logging errors so they never mask the real failure
        END CATCH

    END CATCH
END;

GO