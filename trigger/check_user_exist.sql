CREATE TRIGGER trg_InsertStudent
ON [Users]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert into Student table for users with University_ID >= 2000000 (students)
    -- AND not already in Tutor table
    INSERT INTO [Student] (University_ID, Major, Current_degree)
    SELECT 
        i.University_ID,
        'Computer Science' AS Major,  -- Default or determine from somewhere
        'Bachelor' AS Current_degree   -- Default
    FROM inserted i
    WHERE i.University_ID >= 2000000  -- Student ID pattern
        AND NOT EXISTS (
            SELECT 1 FROM [Tutor] t 
            WHERE t.University_ID = i.University_ID --TODO:Theo Huy nghĩ thì uniID của bọn student vốn đã >2000000, ko thể trùng với admin hay là tutor được .-.
        )
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

    INSERT INTO [Tutor] (University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)
    SELECT 
        i.University_ID,
        CONCAT(i.First_Name, ' ', i.Last_Name) AS [Name],
        NULL AS Academic_Rank,
        NULL AS [Details],
        GETDATE() AS Issuance_Date,
        NULL AS Department_Name
    FROM inserted i
    WHERE i.University_ID <= 9000
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

    INSERT INTO [Admin] (University_ID, [Type])
    SELECT 
        i.University_ID,
        'Coordinator'  AS [Type]   -- Default
    FROM inserted i
    WHERE i.University_ID >= 9000
        AND i.University_ID < 20000    AND NOT EXISTS (
            SELECT 1 FROM [Admin] a
            WHERE a.University_ID = i.University_ID
        );
END;
GO
