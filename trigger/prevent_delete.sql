CREATE TRIGGER trg_PreventUserDelete
ON [Users]
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE EXISTS (SELECT 1 FROM Student WHERE University_ID = deleted.University_ID)
           OR EXISTS (SELECT 1 FROM Tutor WHERE University_ID = deleted.University_ID)
           OR EXISTS (SELECT 1 FROM Admin WHERE University_ID = deleted.University_ID)
    )
    BEGIN
        RAISERROR('Cannot delete a user who belongs to other role tables.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If safe, allow deletion
    DELETE FROM Users
    WHERE University_ID IN (SELECT University_ID FROM deleted);
END
GO
