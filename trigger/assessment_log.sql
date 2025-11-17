CREATE TRIGGER trg_LogAssessmentChanges
ON [Assessment]
AFTER UPDATE
AS
BEGIN
    INSERT INTO Audit_Log (timestamp, affected_entities, grade_updates, deadline_extensions)
    SELECT 
        GETDATE(), 
        CONCAT('Assessment ', i.Section_ID, '-', i.Course_ID, '-', i.Semester, '-', i.Assessment_ID),
        -- Nếu bất kỳ grade nào thay đổi, ghi giá trị mới (Final_Grade hoặc Midterm_Grade hoặc Grade)
        CASE 
            WHEN i.Final_Grade <> d.Final_Grade THEN CONCAT('Final_Grade: ', i.Final_Grade)
            WHEN i.Midterm_Grade <> d.Midterm_Grade THEN CONCAT('Midterm_Grade: ', i.Midterm_Grade)
            WHEN i.Grade <> d.Grade THEN CONCAT('Grade: ', i.Grade)
            ELSE NULL
        END AS grade_updates,
        -- Nếu deadline (Potential_Withdrawal_Date) hoặc status thay đổi
        CASE 
            WHEN i.Potential_Withdrawal_Date <> d.Potential_Withdrawal_Date THEN CONCAT('Old Withdraw: ', d.Potential_Withdrawal_Date, ' New: ', i.Potential_Withdrawal_Date)
            WHEN i.[Status] <> d.[Status] THEN CONCAT('Old Status: ', d.[Status], ' New: ', i.[Status])
            ELSE NULL
        END AS deadline_extensions
    FROM inserted i
    JOIN deleted d 
      ON i.University_ID = d.University_ID
     AND i.Section_ID = d.Section_ID
     AND i.Course_ID = d.Course_ID
     AND i.Semester = d.Semester
     AND i.Assessment_ID = d.Assessment_ID
    -- Chỉ log nếu có thay đổi ít nhất một trường quan trọng
    WHERE i.Final_Grade <> d.Final_Grade
       OR i.Midterm_Grade <> d.Midterm_Grade
       OR i.Grade <> d.Grade
       OR i.Potential_Withdrawal_Date <> d.Potential_Withdrawal_Date
       OR i.[Status] <> d.[Status];
END;
GO
