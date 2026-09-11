-- ============================== Source file: Position_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactPosition]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactPosition';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'Position_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.FactPosition ----
        IF OBJECT_ID(N'ims.FactPosition', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactPosition does not exist.', 1;
        END

        -- Stage source rows (with dimension-key lookups) using a permanent staging table,
        -- since a local #temp table created inside sp_executesql would not survive past that call.
        IF OBJECT_ID(N'dbo.TmpFactPosition', N'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.TmpFactPosition;
        END

        SET @SQL = N'
        SELECT
            s.PositionKey,
            s.AsOfDate,
            po.PortfolioCode,
            s.Identifier,
            s.MarketPrice,
            s.MarketValue,
            s.Originalface,
            s.Currentface,
            s.Quantity,
            s.Factor,
            s.AccruedInterestAmount,
            s.NotionalValue,
            s.Coupon,
            s.TicketId,
            dt.DateKey,
            si.SecurityKey,
            po.PortfolioKey,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        INTO dbo.TmpFactPosition
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].[Position] s
        LEFT JOIN ims.DimPortfolio po
            ON po.PortfolioCode COLLATE Latin1_General_CI_AS = s.PortfolioCode COLLATE Latin1_General_CI_AS
        LEFT JOIN ims.DimSecurityIdentifier si
            ON si.Identifier COLLATE Latin1_General_CI_AS = s.Identifier COLLATE Latin1_General_CI_AS
        LEFT JOIN dbo.DimDate dt
            ON s.AsOfDate = dt.[Date];';
        EXEC sp_executesql @SQL;

        IF (SELECT COUNT(*) FROM dbo.TmpFactPosition) = 0
        BEGIN
            DROP TABLE dbo.TmpFactPosition;
            THROW 50002, 'Row count is zero for TmpFactPosition (source returned no rows).', 1;
        END

        TRUNCATE TABLE ims.FactPosition;

        INSERT INTO ims.FactPosition (
            PositionKey,
            AsofDate,
            PortfolioCode,
            Identifier,
            MarketPrice,
            MarketValue,
            OriginalFace,
            CurrentFace,
            Quantity,
            Factor,
            AccruedInterestAmount,
            NotionalValue,
            Coupon,
            TicketId,
            DateKey,
            SecurityKey,
            PortfolioKey,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.PositionKey,
            s.AsOfDate,
            s.PortfolioCode,
            s.Identifier,
            s.MarketPrice,
            s.MarketValue,
            s.Originalface,
            s.Currentface,
            s.Quantity,
            s.Factor,
            s.AccruedInterestAmount,
            s.NotionalValue,
            s.Coupon,
            s.TicketId,
            s.DateKey,
            s.SecurityKey,
            s.PortfolioKey,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM dbo.TmpFactPosition s;
        SET @RowsInserted += @@ROWCOUNT;

        DROP TABLE dbo.TmpFactPosition;

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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in Position_Gold_Process';
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