USE [lms_system];
GO

-- ============================================
-- Script to SELECT * FROM all tables
-- Excluding: Department, DEPENDENT, EMPLOYEE
-- ============================================

PRINT '========================================';
PRINT 'SELECTING ALL DATA FROM TABLES';
PRINT 'Excluding: Department, DEPENDENT, EMPLOYEE';
PRINT '========================================';
PRINT '';

-- Account
PRINT '--- Account ---';
SELECT * FROM [Account];
PRINT '';

-- Admin
PRINT '--- Admin ---';
SELECT * FROM [Admin];
PRINT '';

-- Assessment
PRINT '--- Assessment ---';
SELECT * FROM [Assessment];
PRINT '';

-- Assignment
PRINT '--- Assignment ---';
SELECT * FROM [Assignment];
PRINT '';

-- Audit_Log
PRINT '--- Audit_Log ---';
SELECT * FROM [Audit_Log];
PRINT '';

-- Building
PRINT '--- Building ---';
SELECT * FROM [Building];
PRINT '';

-- Course
PRINT '--- Course ---';
SELECT * FROM [Course];
PRINT '';

-- Feedback
PRINT '--- Feedback ---';
SELECT * FROM [Feedback];
PRINT '';




