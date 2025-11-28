USE [lms_system];
GO

-- ============================================
-- Script to drop the advanced trigger
-- trg_AutoCreateSectionOnCourseInsertAdvanced
-- ============================================

IF OBJECT_ID('trg_AutoCreateSectionOnCourseInsertAdvanced', 'TR') IS NOT NULL
BEGIN
    DROP TRIGGER trg_AutoCreateSectionOnCourseInsertAdvanced;
    PRINT 'Successfully dropped trigger: trg_AutoCreateSectionOnCourseInsertAdvanced';
END
ELSE
BEGIN
    PRINT 'Trigger trg_AutoCreateSectionOnCourseInsertAdvanced does not exist.';
END
GO

-- Verify trigger is dropped
PRINT '';
PRINT 'Verifying trigger status...';
IF OBJECT_ID('trg_AutoCreateSectionOnCourseInsertAdvanced', 'TR') IS NULL
BEGIN
    PRINT '✓ Confirmed: Trigger has been dropped.';
END
ELSE
BEGIN
    PRINT '✗ Warning: Trigger still exists.';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Drop operation completed.';
PRINT 'Only the simple trigger (trg_AutoCreateSectionOnCourseInsert)';
PRINT 'will now create sections for semester 251 only.';
PRINT '========================================';
GO

