-- ============================================
-- Triggers: Tự động phân loại User vào Student/Tutor/Admin dựa trên University_ID
-- 
-- PHÂN LOẠI RANGES:
-- - Tutor:   1 - 8999
-- - Admin:   9000 - 19999  
-- - Student: 2000000+
-- - Gap:     20000 - 1999999 (reserved/unused)
-- ============================================

-- Xóa triggers cũ nếu tồn tại
IF OBJECT_ID('dbo.trg_InsertStudent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_InsertStudent;
GO
IF OBJECT_ID('dbo.trg_InsertTutor', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_InsertTutor;
GO
IF OBJECT_ID('dbo.trg_InsertAdmin', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_InsertAdmin;
GO

CREATE TRIGGER trg_InsertStudent
ON [Users]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert into Student table for users with University_ID >= 2000000 (students)
    INSERT INTO [Student] (University_ID, Major, Current_degree)
    SELECT 
        i.University_ID,
        'Computer Science' AS Major,  -- Default value
        'Bachelor' AS Current_degree   -- Default value
    FROM inserted i
    WHERE i.University_ID >= 2000000  -- Student ID range
        AND NOT EXISTS (
            SELECT 1 FROM [Student] s 
            WHERE s.University_ID = i.University_ID
        );
END
GO

CREATE TRIGGER trg_InsertTutor
ON [Users]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert into Tutor table for users with University_ID: 1 - 8999
    INSERT INTO [Tutor] (University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)
    SELECT 
        i.University_ID,
        CONCAT(i.First_Name, ' ', i.Last_Name) AS [Name],
        NULL AS Academic_Rank,
        NULL AS [Details],
        GETDATE() AS Issuance_Date,
        NULL AS Department_Name
    FROM inserted i
    WHERE i.University_ID >= 1
        AND i.University_ID < 9000  -- Tutor ID range: 1-8999 (không bao gồm 9000)
        AND NOT EXISTS (
            SELECT 1 FROM [Tutor] t
            WHERE t.University_ID = i.University_ID
        );
END;
GO

CREATE TRIGGER trg_InsertAdmin
ON [Users]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert into Admin table for users with University_ID: 9000 - 19999
    INSERT INTO [Admin] (University_ID, [Type])
    SELECT 
        i.University_ID,
        'Coordinator' AS [Type]   -- Default value
    FROM inserted i
    WHERE i.University_ID >= 9000     -- Admin ID range: 9000-19999
        AND i.University_ID < 20000
        AND NOT EXISTS (
            SELECT 1 FROM [Admin] a
            WHERE a.University_ID = i.University_ID
        );
END;
GO
