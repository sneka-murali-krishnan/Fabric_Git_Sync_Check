CREATE PROCEDURE Log.SP_ETLBatchHeader
                    @PipelineName   VARCHAR(255),
                    @PipelineRunId  VARCHAR(255),
                    @StartTime      DATETIME2(6) = NULL,
                    @EndTime        DATETIME2(6) = NULL,
                    @Status         VARCHAR(255) = NULL,
                    @ErrorMessage   VARCHAR(600) = NULL,
                    @BatchId        INT          = NULL
                AS
                BEGIN
                    DECLARE @DurationInMinutes   INT;
                    DECLARE @ExistingStartTime   DATETIME2(6);
                    DECLARE @NewBatchId          INT;

                    IF @BatchId IS NOT NULL
                    BEGIN
                        SELECT @ExistingStartTime = StartTime
                        FROM Log.ETLBatchHeader
                        WHERE BatchId = @BatchId;

                        IF @ExistingStartTime IS NULL
                        BEGIN
                            THROW 50000, 'Invalid BatchId', 1;
                        END

                        IF @EndTime IS NOT NULL
                        BEGIN
                            SET @DurationInMinutes = DATEDIFF(MINUTE, @ExistingStartTime, @EndTime);
                        END

                        UPDATE Log.ETLBatchHeader
                        SET
                            EndTime           = @EndTime,
                            Status            = @Status,
                            DurationInMinutes = @DurationInMinutes,
                            ErrorMessage      = @ErrorMessage
                        WHERE BatchId = @BatchId;

                        SELECT @BatchId AS BatchId;
                    END
                    ELSE
                    BEGIN
                        SELECT @NewBatchId = COALESCE(MAX(BatchId), 0) + 1
                        FROM Log.ETLBatchHeader;

                        IF @StartTime IS NOT NULL AND @EndTime IS NOT NULL
                        BEGIN
                            SET @DurationInMinutes = DATEDIFF(MINUTE, @StartTime, @EndTime);
                        END

                        INSERT INTO Log.ETLBatchHeader
                        (BatchId, PipelineName, PipelineRunId, StartTime, EndTime,
                         DurationInMinutes, Status, ErrorMessage)
                        VALUES
                        (@NewBatchId, @PipelineName, @PipelineRunId, @StartTime, @EndTime,
                         @DurationInMinutes, COALESCE(@Status, 'In-Progress'), @ErrorMessage);

                        SELECT @NewBatchId AS BatchId;
                    END
                END

GO