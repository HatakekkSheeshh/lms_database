CREATE TRIGGER trg_QuizPassFail
ON [Quiz]
AFTER INSERT, UPDATE
AS
BEGIN
    -- Cập nhật completion_status dựa trên score và pass_score
    UPDATE [Quiz]
    SET completion_status = CASE 
                               WHEN score >= pass_score THEN 'Passed'
                               ELSE 'Failed'
                            END
    FROM [Quiz]
    JOIN inserted i
      ON [Quiz].University_ID = i.University_ID
     AND [Quiz].Section_ID = i.Section_ID
     AND [Quiz].Course_ID = i.Course_ID
     AND [Quiz].Semester = i.Semester
     AND [Quiz].Assessment_ID = i.Assessment_ID;
END;
GO


CREATE TRIGGER trg_QuizHighestAttempt
ON [Quiz]
AFTER INSERT, UPDATE
AS
BEGIN
    -- Chỉ áp dụng cho học sinh có Grading_method = 'Highest Attempt'
    DECLARE @uid DECIMAL(7,0), @sec NVARCHAR(10), @cid NVARCHAR(15), @sem NVARCHAR(10), @aid INT;

    -- Lặp qua các row vừa insert/update
    DECLARE cur CURSOR FOR
    SELECT University_ID, Section_ID, Course_ID, Semester, Assessment_ID
    FROM inserted;

    OPEN cur;
    FETCH NEXT FROM cur INTO @uid, @sec, @cid, @sem, @aid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @max_score DECIMAL(4,2);

        SELECT @max_score = MAX(score)
        FROM Quiz
        WHERE University_ID = @uid
          AND Section_ID = @sec
          AND Course_ID = @cid
          AND Semester = @sem
          AND Assessment_ID = @aid
          AND Grading_method = 'Highest Attempt';

        -- Cập nhật tất cả attempt để giữ score = max_score
        UPDATE Quiz
        SET score = @max_score
        WHERE University_ID = @uid
          AND Section_ID = @sec
          AND Course_ID = @cid
          AND Semester = @sem
          AND Assessment_ID = @aid
          AND Grading_method = 'Highest Attempt';

        FETCH NEXT FROM cur INTO @uid, @sec, @cid, @sem, @aid;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
