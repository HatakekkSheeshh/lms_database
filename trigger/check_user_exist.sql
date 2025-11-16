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
            WHERE t.University_ID = i.University_ID
        )
        AND NOT EXISTS (
            SELECT 1 FROM [Student] s 
            WHERE s.University_ID = i.University_ID
        );
END
GO