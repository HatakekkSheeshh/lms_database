USE [lms_system];
GO

-- ============================================
-- Example: Test procedure to create course with custom sections
-- Course: "Game Programming" (CO3045)
-- Sections: 3 CC, 5 L, 2 KSTN
-- ============================================

PRINT '========================================';
PRINT 'Testing sp_CreateCourseWithSections';
PRINT 'Course: Game Programming (CO3045)';
PRINT 'Sections: 3 CC, 5 L, 2 KSTN';
PRINT 'Expected: CC01, CC02, CC03, L01, L02, L03, L04, L05, KSTN1, KSTN2';
PRINT '========================================';
PRINT '';

-- Step 1: Preview sections before creating
PRINT 'Step 1: Preview sections that will be created...';
EXEC sp_GetSectionIDsByCount
    @CC_Count = 3,
    @L_Count = 5,
    @KSTN_Count = 2;
PRINT '';

-- Step 2: Check if course exists
PRINT 'Step 2: Checking if course CO3045 exists...';
IF EXISTS (SELECT 1 FROM [Course] WHERE Course_ID = 'CO3045')
BEGIN
    PRINT '  Course CO3045 already exists. Deleting it first...';
    DELETE FROM [Scheduler] WHERE Course_ID = 'CO3045';
    DELETE FROM [Section] WHERE Course_ID = 'CO3045';
    DELETE FROM [Course] WHERE Course_ID = 'CO3045';
    PRINT '  Deleted existing course and related records.';
END
ELSE
BEGIN
    PRINT '  Course CO3045 does not exist. Proceeding...';
END
PRINT '';

-- Step 3: Create course with custom sections
PRINT 'Step 3: Creating course with custom sections...';
EXEC sp_CreateCourseWithSections
    @Course_ID = 'CO3045',
    @Course_Name = 'Game Programming',
    @Credit = 3,
    @Semester = '242',
    @CC_Count = 3,
    @L_Count = 5,
    @KSTN_Count = 2;
PRINT '';

-- Step 4: Verify results
PRINT 'Step 4: Verifying created sections...';
SELECT 
    Section_ID,
    Course_ID,
    Semester
FROM [Section]
WHERE Course_ID = 'CO3045'
ORDER BY 
    CASE 
        WHEN Section_ID LIKE 'CC%' THEN 1
        WHEN Section_ID LIKE 'L%' THEN 2
        WHEN Section_ID LIKE 'KSTN%' THEN 3
    END,
    Section_ID;
PRINT '';

DECLARE @SectionCount INT;
SELECT @SectionCount = COUNT(*)
FROM [Section]
WHERE Course_ID = 'CO3045';

IF @SectionCount = 10
BEGIN
    PRINT '  ✓ SUCCESS: 10 sections created as expected';
END
ELSE
BEGIN
    PRINT '  ✗ ERROR: Expected 10 sections, but found ' + CAST(@SectionCount AS NVARCHAR(10));
END
PRINT '';

-- Step 5: Note about Scheduler
PRINT 'Step 5: Note about Scheduler';
PRINT '  Note: Scheduler records are NOT created automatically.';
PRINT '        They can be created separately if needed.';
PRINT '';

PRINT '========================================';
PRINT 'Test completed!';
PRINT '========================================';
GO

