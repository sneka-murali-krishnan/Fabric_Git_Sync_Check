-- ============================== Source file: StandardAnalytics_Gold_Process.sql ==============================
CREATE   PROCEDURE [ims].[sp_FactStandardAnalytics]
    @SilverLakehouse VARCHAR(MAX) = 'LH_Silver'
    ,@BatchId INT = NULL
/*
© UB Technology Innovations. Unauthorized use or reproduction is prohibited
*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName    VARCHAR(200)   = 'FactStandardAnalytics';
    DECLARE @SchemaName VARCHAR(255) = 'ims';
    DECLARE @ProcedureName VARCHAR(256)  = 'StandardAnalytics_Gold_Process';
    DECLARE @ErrorMessage VARCHAR(8000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;
    DECLARE @StartTime     DATETIME2(6)  = SYSUTCDATETIME();
    DECLARE @EndTime       DATETIME2(6);
    DECLARE @Duration      VARCHAR(50);
    DECLARE @RowsInserted  INT = 0;
    DECLARE @SQL           NVARCHAR(MAX);

    BEGIN TRY

        -- ---- Target: ims.FactStandardAnalytics ----
        IF OBJECT_ID(N'ims.FactStandardAnalytics', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactStandardAnalytics does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactStandardAnalytics;

        SET @SQL = N'INSERT INTO ims.FactStandardAnalytics (
            StandardAnalyticsKey,
            SecurityKey,
            EffectiveDt,
            StandardSourceKey,
            StandardSourceFieldKey,
            Value,
            CreatedBy,
            CreatedDate,
            UpdatedBy,
            UpdatedDate
        )
        SELECT
            s.StandardAnalyticsKey,
            si.SecurityKey,
            s.AsOfDate,
            ss.StandardSourceKey,
            ssf.StandardSourceFieldKey,
            s.Value,
            s.CreatedBy,
            s.CreatedDate,
            s.UpdatedBy,
            s.UpdatedDate
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StandardAnalytics s
        LEFT JOIN ims.FactStandardAnalytics d
            ON s.StandardAnalyticsKey = d.StandardAnalyticsKey
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].SecurityIdentifier si
            ON si.Identifier = s.Symbol AND si.IdentifierType = ''SYMBOL''
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StandardSource ss
            ON ss.Name = s.Source
        INNER JOIN ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StandardSourceFields ssf
            ON ssf.Code = s.Field;';
        EXEC sp_executesql @SQL;
        SET @RowsInserted += @@ROWCOUNT;

        -- ---- Target: ims.FactStandardAnalyticsExt ----
        IF OBJECT_ID(N'ims.FactStandardAnalyticsExt', N'U') IS NULL
        BEGIN
            THROW 50000, 'Invalid operation. Table ims.FactStandardAnalyticsExt does not exist.', 1;
        END

        TRUNCATE TABLE ims.FactStandardAnalyticsExt;

        SET @SQL = N'INSERT INTO ims.FactStandardAnalyticsExt (
            StandardAnalyticsKey
        )
        SELECT
            s.StandardAnalyticsKey
        FROM ' + QUOTENAME(@SilverLakehouse) + N'.[dbo].StandardAnalyticsExt s
        LEFT JOIN ims.FactStandardAnalyticsExt d ON s.StandardAnalyticsKey = d.StandardAnalyticsKey;';
        EXEC sp_executesql @SQL;
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
        SET @ErrorMessage = ERROR_MESSAGE() + ' in StandardAnalytics_Gold_Process';
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