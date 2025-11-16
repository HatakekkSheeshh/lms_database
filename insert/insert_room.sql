USE [lms_system];
GO

DECLARE @Current_Building_ID INT;
DECLARE building_cursor CURSOR FOR
SELECT Building_ID FROM [Building];

OPEN building_cursor;
FETCH NEXT FROM building_cursor INTO @Current_Building_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    
    DECLARE @Counter INT = 1;
    DECLARE @Capacity_To_Insert INT;

    WHILE @Counter <= 20
    BEGIN
        
        SET @Capacity_To_Insert = CASE @Counter % 7
                                    WHEN 1 THEN 40
                                    WHEN 2 THEN 60
                                    WHEN 3 THEN 40
                                    WHEN 4 THEN 60
                                    WHEN 5 THEN 40
                                    WHEN 6 THEN 60
                                    ELSE 80 
                                  END;

        INSERT INTO [Room] (Building_ID, Capacity)
        VALUES (@Current_Building_ID, @Capacity_To_Insert);

        SET @Counter = @Counter + 1;
    END;

    FETCH NEXT FROM building_cursor INTO @Current_Building_ID;
END;

CLOSE building_cursor;
DEALLOCATE building_cursor;