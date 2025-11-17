CREATE TRIGGER trg_StudentSingleCourse
ON [Assessment]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN [Assessment] a
          ON i.University_ID = a.University_ID
         AND i.Course_ID = a.Course_ID      -- cùng môn
         AND i.Semester = a.Semester        -- cùng học kỳ
         AND i.Section_ID <> a.Section_ID   -- khác section
    )
    BEGIN
        RAISERROR('A student cannot enroll in more than one section of the same course in the same semester.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
