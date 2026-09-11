-- ============================== Source file: sp_UpdateRowCountAudit.sql ==============================
CREATE   PROCEDURE [ims].[sp_UpdateRowCountAudit]
    @BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(200) = 'sp_UpdateRowCountAudit'; -- Added declaration and assignment
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @StartTime DATETIME2(6) = SYSUTCDATETIME();
    DECLARE @EndTime DATETIME2(6);
    DECLARE @Duration VARCHAR(50);

    BEGIN TRY

        -----------------------------------------------------------------------
        -- Declare Variables
        -----------------------------------------------------------------------
        DECLARE
            @TableId BIGINT,
            @SchemaName VARCHAR(200),
            @AuditTableName VARCHAR(200),
            @PrevRowCount INT,
            @CurRowCount INT,
            @PercentageChange DECIMAL(19,2),
            @TodayDate DATE = CAST(DATEADD(HOUR,-8,GETUTCDATE()) AS DATE),
            @SQL NVARCHAR(MAX),
            @YesterdayDate DATE,
            @RowCount INT,
            @Index INT = 1;

        DECLARE @YesterdayTemp DATE =
            CAST(DATEADD(DAY,-1,DATEADD(HOUR,-8,GETUTCDATE())) AS DATE);

        SET @YesterdayDate =
            CASE
                WHEN DATEPART(WEEKDAY,@YesterdayTemp) = 1
                    THEN CAST(DATEADD(DAY,-2,@YesterdayTemp) AS DATE)
                WHEN DATEPART(WEEKDAY,@YesterdayTemp) = 7
                    THEN CAST(DATEADD(DAY,-1,@YesterdayTemp) AS DATE)
                ELSE @YesterdayTemp
            END;

        -----------------------------------------------------------------------
        -- Process Active Audit Tables
        -----------------------------------------------------------------------
        SET @RowCount =
        (
            SELECT COUNT(*)
            FROM dbo.TableRowCountAudit
            WHERE IsActive = 1
        );

        WHILE @Index <= @RowCount
        BEGIN

            SELECT
                @TableId = TableId,
                @SchemaName = SchemaName,
                @AuditTableName = TableName
            FROM
            (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY TableId) AS RowNum,
                    *
                FROM dbo.TableRowCountAudit
                WHERE IsActive = 1
            ) Temp
            WHERE RowNum = @Index;

            DECLARE @YesterdayRowCount INT = 0;
            DECLARE @TodayRowCount INT = 0;

            SET @SQL = '
                SELECT @YesterdayRowCountOut = COUNT(*)
                FROM ' + QUOTENAME(@SchemaName) + '.'
                         + QUOTENAME(@AuditTableName) + '
                WHERE CreatedDate >= @YesterdayDate
                  AND CreatedDate < @TodayDate;

                SELECT @TodayRowCountOut = COUNT(*)
                FROM ' + QUOTENAME(@SchemaName) + '.'
                         + QUOTENAME(@AuditTableName) + '
                WHERE CreatedDate >= @TodayDate;
            ';

            EXEC sp_executesql
                @SQL,
                N'@YesterdayRowCountOut INT OUTPUT,
                  @TodayRowCountOut INT OUTPUT,
                  @YesterdayDate DATE,
                  @TodayDate DATE',
                @YesterdayRowCountOut = @YesterdayRowCount OUTPUT,
                @TodayRowCountOut = @TodayRowCount OUTPUT,
                @YesterdayDate = @YesterdayDate,
                @TodayDate = @TodayDate;

            SET @PrevRowCount = ISNULL(@YesterdayRowCount,0);
            SET @CurRowCount = ISNULL(@TodayRowCount,0);

            IF @PrevRowCount > 0
                SET @PercentageChange =
                    ((@CurRowCount - @PrevRowCount) * 100.0)
                    / @PrevRowCount;
            ELSE IF @PrevRowCount = 0
                 AND @CurRowCount = 0
                SET @PercentageChange = 0.00;
            ELSE
                SET @PercentageChange = 100.00;

            UPDATE dbo.TableRowCountAudit
            SET
                PrevRowCount = @PrevRowCount,
                CurRowCount = @CurRowCount,
                PercentageChange = @PercentageChange,
                LastSyncTime = DATEADD(HOUR,-8,GETUTCDATE())
            WHERE TableId = @TableId;

            SET @Index += 1;

        END;

        -----------------------------------------------------------------------
        -- Return Significant Changes
        -----------------------------------------------------------------------
        SELECT
            TableName,
            PrevRowCount,
            CurRowCount,
            PercentageChange
        FROM dbo.TableRowCountAudit
        WHERE ABS(PercentageChange) >= 10
          AND IsActive = 1;

        -----------------------------------------------------------------------
        -- Success Logging
        -----------------------------------------------------------------------
        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
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
                'sp_UpdateRowCountAudit'
            );
        END TRY
        BEGIN CATCH
            -- Swallow audit-log failures (e.g. cross-warehouse write issues to
            -- WH_MetaData) so they never mask a data step that already succeeded.
        END CATCH

    END TRY
    BEGIN CATCH

        SET @ErrorMessage =
            ERROR_MESSAGE() + ' in UpdateRowCountAudit';

        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        SET @EndTime = SYSUTCDATETIME();

        SET @Duration =
            CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR(20))
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
                'sp_UpdateRowCountAudit'
            );

        END TRY
        BEGIN CATCH
            -- Swallow logging errors
        END CATCH

    END CATCH

END;

GO