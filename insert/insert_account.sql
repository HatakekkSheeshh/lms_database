USE [database_systems_asm2];
GO

DECLARE @Current_User_ID DECIMAL(7,0);
DECLARE @Default_Password NVARCHAR(50);

DECLARE user_cursor CURSOR FOR
SELECT University_ID FROM [Users];

OPEN user_cursor;

FETCH NEXT FROM user_cursor 
INTO @Current_User_ID;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @Default_Password = N'user' + CAST(@Current_User_ID AS NVARCHAR(7));

    INSERT INTO [Account] (University_ID, [Password])
    VALUES (@Current_User_ID, @Default_Password);

    FETCH NEXT FROM user_cursor 
    INTO @Current_User_ID;
END;

CLOSE user_cursor;
DEALLOCATE user_cursor;
