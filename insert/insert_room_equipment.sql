USE [lms_system];
GO

DELETE FROM [Room_Equipment];
GO

DECLARE @Current_Building_Name NVARCHAR(10);
DECLARE @Current_Room_Name NVARCHAR(10);
DECLARE @Current_Capacity INT;

DECLARE room_cursor CURSOR FOR
SELECT Building_Name, Room_Name, Capacity 
FROM [Room]
WHERE Building_Name IS NOT NULL AND Room_Name IS NOT NULL;

OPEN room_cursor;

FETCH NEXT FROM room_cursor INTO @Current_Building_Name, @Current_Room_Name, @Current_Capacity;

WHILE @@FETCH_STATUS = 0
BEGIN

    INSERT INTO [Room_Equipment] (Building_Name, Room_Name, Equipment_Name)
    VALUES
        (@Current_Building_Name, @Current_Room_Name, 'Whiteboard'),
        (@Current_Building_Name, @Current_Room_Name, 'Dry-erase marker'),
        (@Current_Building_Name, @Current_Room_Name, 'Power outlet'),
        (@Current_Building_Name, @Current_Room_Name, 'Air conditioner');

    IF @Current_Capacity > 50
    BEGIN
        INSERT INTO [Room_Equipment] (Building_Name, Room_Name, Equipment_Name)
        VALUES
            (@Current_Building_Name, @Current_Room_Name, 'Projector'),
            (@Current_Building_Name, @Current_Room_Name, 'Projection screen'),
            (@Current_Building_Name, @Current_Room_Name, 'Sound system (Speakers/Mic)');
    END;

    IF @Current_Capacity <= 40
    BEGIN
        INSERT INTO [Room_Equipment] (Building_Name, Room_Name, Equipment_Name)
        VALUES
            (@Current_Building_Name, @Current_Room_Name, 'Blackboard'),
            (@Current_Building_Name, @Current_Room_Name, 'Chalk');
    END;

    FETCH NEXT FROM room_cursor INTO @Current_Building_Name, @Current_Room_Name, @Current_Capacity;
END;

CLOSE room_cursor;
DEALLOCATE room_cursor;
