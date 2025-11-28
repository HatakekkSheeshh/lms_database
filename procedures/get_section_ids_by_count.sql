USE [lms_system];
GO

IF OBJECT_ID('sp_GetSectionIDsByCount', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSectionIDsByCount;
GO

CREATE PROCEDURE sp_GetSectionIDsByCount
    @CC_Count INT = 0,  -- Number of CC sections
    @L_Count INT = 0,   -- Number of L sections
    @KSTN_Count INT = 0 -- Number of KSTN sections
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create table to return
    DECLARE @Result TABLE (
        Section_ID NVARCHAR(10),
        Prefix NVARCHAR(10),
        Number INT,
        Display_Order INT
    );
    
    -- Generate CC sections
    DECLARE @CC_Counter INT = 1;
    DECLARE @DisplayOrder INT = 1;
    WHILE @CC_Counter <= @CC_Count
    BEGIN
        DECLARE @CC_Section_ID NVARCHAR(10);
        IF @CC_Counter < 10
            SET @CC_Section_ID = 'CC0' + CAST(@CC_Counter AS NVARCHAR(1));
        ELSE
            SET @CC_Section_ID = 'CC' + CAST(@CC_Counter AS NVARCHAR(10));
        
        INSERT INTO @Result (Section_ID, Prefix, Number, Display_Order)
        VALUES (@CC_Section_ID, 'CC', @CC_Counter, @DisplayOrder);
        
        SET @CC_Counter = @CC_Counter + 1;
        SET @DisplayOrder = @DisplayOrder + 1;
    END
    
    -- Generate L sections
    DECLARE @L_Counter INT = 1;
    WHILE @L_Counter <= @L_Count
    BEGIN
        DECLARE @L_Section_ID NVARCHAR(10);
        IF @L_Counter < 10
            SET @L_Section_ID = 'L0' + CAST(@L_Counter AS NVARCHAR(1));
        ELSE
            SET @L_Section_ID = 'L' + CAST(@L_Counter AS NVARCHAR(10));
        
        INSERT INTO @Result (Section_ID, Prefix, Number, Display_Order)
        VALUES (@L_Section_ID, 'L', @L_Counter, @DisplayOrder);
        
        SET @L_Counter = @L_Counter + 1;
        SET @DisplayOrder = @DisplayOrder + 1;
    END
    
    -- Generate KSTN sections
    DECLARE @KSTN_Counter INT = 1;
    WHILE @KSTN_Counter <= @KSTN_Count
    BEGIN
        DECLARE @KSTN_Section_ID NVARCHAR(10) = 'KSTN' + CAST(@KSTN_Counter AS NVARCHAR(10));
        
        INSERT INTO @Result (Section_ID, Prefix, Number, Display_Order)
        VALUES (@KSTN_Section_ID, 'KSTN', @KSTN_Counter, @DisplayOrder);
        
        SET @KSTN_Counter = @KSTN_Counter + 1;
        SET @DisplayOrder = @DisplayOrder + 1;
    END
    
    -- Return results
    SELECT 
        Section_ID,
        Prefix,
        Number
    FROM @Result
    ORDER BY Display_Order;
END;
GO

