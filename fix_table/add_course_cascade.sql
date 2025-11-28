USE [lms_system];
GO


-- Drop existing FK constraint from Section to Course
IF EXISTS (SELECT 1 FROM sys.foreign_keys 
           WHERE name = 'FK_Section_Course' 
           AND parent_object_id = OBJECT_ID('Section'))
BEGIN
    ALTER TABLE [Section]
    DROP CONSTRAINT FK_Section_Course;
    PRINT 'Dropped existing FK_Section_Course constraint';
END
GO

-- Recreate FK with ON UPDATE CASCADE
ALTER TABLE [Section]
ADD CONSTRAINT FK_Section_Course 
    FOREIGN KEY (Course_ID)
    REFERENCES [Course](Course_ID)
    ON UPDATE CASCADE;
    -- Note: ON DELETE CASCADE is not added to prevent accidental deletion
PRINT 'Created FK_Section_Course with ON UPDATE CASCADE';
GO

