USE [lms_system];
GO

DELETE FROM [Room_Equipment];
GO

DECLARE @Current_Building_Name NVARCHAR(10);
DECLARE @Current_Room_ID INT;
DECLARE @Current_Capacity INT;

DECLARE room_cursor CURSOR FOR
SELECT Building_Name, Room_ID, Capacity 
FROM [Room];

OPEN room_cursor;

FETCH NEXT FROM room_cursor INTO @Current_Building_Name, @Current_Room_ID, @Current_Capacity;

WHILE @@FETCH_STATUS = 0
BEGIN

    INSERT INTO [Room_Equipment] (Building_Name, Room_ID, Equipment_Name)
    VALUES
        (@Current_Building_Name, @Current_Room_ID, 'Whiteboard'),
        (@Current_Building_Name, @Current_Room_ID, 'Dry-erase marker'),
        (@Current_Building_Name, @Current_Room_ID, 'Power outlet'),
        (@Current_Building_Name, @Current_Room_ID, 'Air conditioner');

    IF @Current_Capacity > 50
    BEGIN
        INSERT INTO [Room_Equipment] (Building_Name, Room_ID, Equipment_Name)
        VALUES
            (@Current_Building_Name, @Current_Room_ID, 'Projector'),
            (@Current_Building_Name, @Current_Room_ID, 'Projection screen'),
            (@Current_Building_Name, @Current_Room_ID, 'Sound system (Speakers/Mic)');
    END;

    IF @Current_Capacity <= 40
    BEGIN
        INSERT INTO [Room_Equipment] (Building_Name, Room_ID, Equipment_Name)
        VALUES
            (@Current_Building_Name, @Current_Room_ID, 'Blackboard'),
            (@Current_Building_Name, @Current_Room_ID, 'Chalk');
    END;

    FETCH NEXT FROM room_cursor INTO @Current_Building_Name, @Current_Room_ID, @Current_Capacity;
END;

CLOSE room_cursor;
DEALLOCATE room_cursor;
