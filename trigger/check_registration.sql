-- ============================================
-- Trigger: trg_StudentSingleCourse
-- Mục đích: Ngăn student đăng ký nhiều hơn 1 section của cùng một môn trong cùng học kỳ
-- Lưu ý: Khuyến nghị dùng UNIQUE CONSTRAINT thay vì trigger để tránh race condition
-- ============================================

-- Xóa trigger cũ nếu tồn tại
IF OBJECT_ID('dbo.trg_StudentSingleCourse', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_StudentSingleCourse;
GO

CREATE TRIGGER trg_StudentSingleCourse
ON [Assessment]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kiểm tra xem có student nào đăng ký >1 section của cùng course/semester không
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Assessment a
            ON i.University_ID = a.University_ID
           AND i.Course_ID = a.Course_ID
           AND i.Semester = a.Semester
           AND i.Section_ID <> a.Section_ID
           -- Loại trừ chính record vừa insert/update
           AND NOT (
               a.Section_ID = i.Section_ID
               AND a.Course_ID = i.Course_ID
               AND a.Semester = i.Semester
               AND a.Assessment_ID = i.Assessment_ID
           )
    )
    BEGIN
        RAISERROR('A student cannot enroll in more than one section of the same course in the same semester.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
