-- ============================================
-- Trigger: trg_LogAssessmentChanges
-- Mục đích: Log mọi thay đổi về điểm và status trong Assessment
-- ============================================

-- Xóa trigger cũ nếu tồn tại
IF OBJECT_ID('dbo.trg_LogAssessmentChanges', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_LogAssessmentChanges;
GO

CREATE TRIGGER trg_LogAssessmentChanges
ON [Assessment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert vào Audit_Log và lấy LogID vừa tạo
    DECLARE @LogIDTable TABLE (LogID INT);
    
    INSERT INTO Audit_Log ([timestamp], affected_entities, grade_updates, deadline_extensions)
    OUTPUT INSERTED.LogID INTO @LogIDTable
    SELECT 
        GETDATE() AS [timestamp],
        CONCAT('Assessment ', i.Section_ID, '-', i.Course_ID, '-', i.Semester, '-', i.Assessment_ID) AS affected_entities,
        -- Ghi tất cả các thay đổi về grade (nối chuỗi)
        NULLIF(CONCAT(
            CASE 
                WHEN ISNULL(i.Final_Grade, -999) <> ISNULL(d.Final_Grade, -999) 
                THEN CONCAT('Final_Grade: ', ISNULL(CAST(d.Final_Grade AS NVARCHAR), 'NULL'), ' -> ', ISNULL(CAST(i.Final_Grade AS NVARCHAR), 'NULL'), '; ')
                ELSE ''
            END,
            CASE 
                WHEN ISNULL(i.Midterm_Grade, -999) <> ISNULL(d.Midterm_Grade, -999)
                THEN CONCAT('Midterm_Grade: ', ISNULL(CAST(d.Midterm_Grade AS NVARCHAR), 'NULL'), ' -> ', ISNULL(CAST(i.Midterm_Grade AS NVARCHAR), 'NULL'), '; ')
                ELSE ''
            END,
            CASE 
                WHEN ISNULL(i.Quiz_Grade, -999) <> ISNULL(d.Quiz_Grade, -999)
                THEN CONCAT('Quiz_Grade: ', ISNULL(CAST(d.Quiz_Grade AS NVARCHAR), 'NULL'), ' -> ', ISNULL(CAST(i.Quiz_Grade AS NVARCHAR), 'NULL'), '; ')
                ELSE ''
            END,
            CASE 
                WHEN ISNULL(i.Assignment_Grade, -999) <> ISNULL(d.Assignment_Grade, -999)
                THEN CONCAT('Assignment_Grade: ', ISNULL(CAST(d.Assignment_Grade AS NVARCHAR), 'NULL'), ' -> ', ISNULL(CAST(i.Assignment_Grade AS NVARCHAR), 'NULL'), '; ')
                ELSE ''
            END
        ), '') AS grade_updates,
        -- Ghi thay đổi về deadline và status
        NULLIF(CONCAT(
            CASE 
                WHEN ISNULL(CONVERT(NVARCHAR, i.Potential_Withdrawal_Date, 120), '') <> ISNULL(CONVERT(NVARCHAR, d.Potential_Withdrawal_Date, 120), '')
                THEN CONCAT('Withdrawal_Date: ', ISNULL(CONVERT(NVARCHAR, d.Potential_Withdrawal_Date, 120), 'NULL'), ' -> ', ISNULL(CONVERT(NVARCHAR, i.Potential_Withdrawal_Date, 120), 'NULL'), '; ')
                ELSE ''
            END,
            CASE 
                WHEN ISNULL(i.[Status], '') <> ISNULL(d.[Status], '')
                THEN CONCAT('Status: ', ISNULL(d.[Status], 'NULL'), ' -> ', ISNULL(i.[Status], 'NULL'), '; ')
                ELSE ''
            END
        ), '') AS deadline_extensions
    FROM inserted i
    INNER JOIN deleted d 
        ON i.University_ID = d.University_ID
       AND i.Section_ID = d.Section_ID
       AND i.Course_ID = d.Course_ID
       AND i.Semester = d.Semester
       AND i.Assessment_ID = d.Assessment_ID
    WHERE 
        -- Chỉ log nếu có thay đổi thực sự
        ISNULL(i.Final_Grade, -999) <> ISNULL(d.Final_Grade, -999)
        OR ISNULL(i.Midterm_Grade, -999) <> ISNULL(d.Midterm_Grade, -999)
        OR ISNULL(i.Quiz_Grade, -999) <> ISNULL(d.Quiz_Grade, -999)
        OR ISNULL(i.Assignment_Grade, -999) <> ISNULL(d.Assignment_Grade, -999)
        OR ISNULL(CONVERT(NVARCHAR, i.Potential_Withdrawal_Date, 120), '') <> ISNULL(CONVERT(NVARCHAR, d.Potential_Withdrawal_Date, 120), '')
        OR ISNULL(i.[Status], '') <> ISNULL(d.[Status], '');
    
    -- Insert vào Reference_To để liên kết log với student
    INSERT INTO Reference_To (LogID, University_ID)
    SELECT l.LogID, i.University_ID
    FROM @LogIDTable l
    CROSS JOIN inserted i;
END;
GO
