USE [lms_system];
GO

-- ============================================
-- Procedure to create course with custom sections
-- Input: Course details + number of sections for each prefix
-- Output: Table of created section IDs
-- ============================================

IF OBJECT_ID('sp_CreateCourseWithSections', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateCourseWithSections;
GO

CREATE PROCEDURE sp_CreateCourseWithSections
    @Course_ID NVARCHAR(15),
    @Course_Name NVARCHAR(100),
    @Credit INT = NULL,
    @Semester NVARCHAR(10) = '242', -- Default: latest semester
    @CC_Count INT = 2,  -- Number of CC sections (CC01, CC02, ...)
    @L_Count INT = 2,   -- Number of L sections (L01, L02, ...)
    @KSTN_Count INT = 1 -- Number of KSTN sections (KSTN1, KSTN2, ...)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(MAX) = '';
    
    -- Validate inputs
    IF @Course_ID IS NULL OR LEN(@Course_ID) = 0
    BEGIN
        SET @ErrorMessage = 'Course_ID cannot be NULL or empty.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END
    
    IF @Course_Name IS NULL OR LEN(@Course_Name) = 0
    BEGIN
        SET @ErrorMessage = 'Course_Name cannot be NULL or empty.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END
    
    IF @CC_Count < 0 OR @L_Count < 0 OR @KSTN_Count < 0
    BEGIN
        SET @ErrorMessage = 'Section counts cannot be negative.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END
    
    IF @CC_Count = 0 AND @L_Count = 0 AND @KSTN_Count = 0
    BEGIN
        SET @ErrorMessage = 'At least one section type must have count > 0.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if course already exists
        IF EXISTS (SELECT 1 FROM [Course] WHERE Course_ID = @Course_ID)
        BEGIN
            SET @ErrorMessage = 'Course ' + @Course_ID + ' already exists.';
            RAISERROR(@ErrorMessage, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        INSERT INTO [Course] (Course_ID, [Name], Credit)
        VALUES (@Course_ID, @Course_Name, @Credit);
        
        PRINT 'Course ' + @Course_ID + ' (' + @Course_Name + ') created successfully.';
        
        -- Trigger creates default sections
        DELETE FROM [Section]
        WHERE Course_ID = @Course_ID 
        AND Semester = @Semester;
        
        PRINT 'Cleared any default sections created by trigger.';
        
        -- Create table to store section IDs
        DECLARE @SectionIDs TABLE (
            Section_ID NVARCHAR(10),
            Prefix NVARCHAR(10),
            Number INT
        );
        
        -- Generate CC sections
        DECLARE @CC_Counter INT = 1;
        WHILE @CC_Counter <= @CC_Count
        BEGIN
            DECLARE @CC_Section_ID NVARCHAR(10);
            IF @CC_Counter < 10
                SET @CC_Section_ID = 'CC0' + CAST(@CC_Counter AS NVARCHAR(1));
            ELSE
                SET @CC_Section_ID = 'CC' + CAST(@CC_Counter AS NVARCHAR(10));
            
            INSERT INTO @SectionIDs (Section_ID, Prefix, Number)
            VALUES (@CC_Section_ID, 'CC', @CC_Counter);
            
            SET @CC_Counter = @CC_Counter + 1;
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
            
            INSERT INTO @SectionIDs (Section_ID, Prefix, Number)
            VALUES (@L_Section_ID, 'L', @L_Counter);
            
            SET @L_Counter = @L_Counter + 1;
        END
        
        -- Generate KSTN sections
        DECLARE @KSTN_Counter INT = 1;
        WHILE @KSTN_Counter <= @KSTN_Count
        BEGIN
            DECLARE @KSTN_Section_ID NVARCHAR(10) = 'KSTN' + CAST(@KSTN_Counter AS NVARCHAR(10));
            
            INSERT INTO @SectionIDs (Section_ID, Prefix, Number)
            VALUES (@KSTN_Section_ID, 'KSTN', @KSTN_Counter);
            
            SET @KSTN_Counter = @KSTN_Counter + 1;
        END
        
        -- Insert sections into Section table
        INSERT INTO [Section] (Section_ID, Course_ID, Semester)
        SELECT Section_ID, @Course_ID, @Semester
        FROM @SectionIDs;
        
        PRINT 'Created ' + CAST((@CC_Count + @L_Count + @KSTN_Count) AS NVARCHAR(10)) + ' sections for course ' + @Course_ID + ' in semester ' + @Semester + '.';
        PRINT 'Note: Scheduler records can be created separately if needed.';
        
        -- Return table of created section IDs
        SELECT 
            Section_ID,
            Prefix,
            Number,
            @Course_ID AS Course_ID,
            @Semester AS Semester
        FROM @SectionIDs
        ORDER BY 
            CASE Prefix
                WHEN 'CC' THEN 1
                WHEN 'L' THEN 2
                WHEN 'KSTN' THEN 3
            END,
            Number;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR('Error creating course with sections: %s', 16, 1, @ErrorMsg);
    END CATCH
END;
GO

