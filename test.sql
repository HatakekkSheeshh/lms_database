USE [lms_system]

DECLARE @sql NVARCHAR(max) = N''
SELECT @sql = @sql + N'' + k
FROM sys.key_constraints as k
WHERE k.[type] = 'PK'

-- Example: Stored Procedure with Transaction
CREATE PROCEDURE sp_ExampleWithTransaction
    @Param1 INT,
    @Param2 VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declare error handling variables
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @TransactionCount INT = @@TRANCOUNT;
    
    -- Begin transaction
    IF @TransactionCount = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION SavePoint;
    
    BEGIN TRY
        -- Your business logic here
        -- Example: Insert operation
        INSERT INTO YourTable (Column1, Column2)
        VALUES (@Param1, @Param2);
        
        -- Example: Update operation
        UPDATE YourTable
        SET Column2 = @Param2
        WHERE Column1 = @Param1;
        
        -- Example: Delete operation
        DELETE FROM YourTable
        WHERE Column1 = @Param1;
        
        -- If all operations succeed, commit transaction
        IF @TransactionCount = 0
            COMMIT TRANSACTION;
        
        -- Return success
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Get error information
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        
        -- Rollback transaction
        IF @TransactionCount = 0
            ROLLBACK TRANSACTION;
        ELSE
            ROLLBACK TRANSACTION SavePoint;
        
        -- Raise error
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        
        -- Return error code
        RETURN -1;
        
    END CATCH;
END;
GO

-- Example of calling the procedure
BEGIN TRAN
    EXEC sp_ExampleWithTransaction @Param1 = 1, @Param2 = 'Test'
    -- If procedure succeeds, commit; if it fails, rollback is handled in procedure
    -- But you can also control it from here
    IF @@ERROR = 0
        COMMIT TRAN
    ELSE
        ROLLBACK TRAN
GO