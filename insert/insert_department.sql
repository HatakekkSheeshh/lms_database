USE [database_systems_asm2];
GO

-- Step 1: Insert Departments with NULL for the University_ID (Chair)
INSERT INTO [Department] (Department_Name, University_ID) VALUES
(N'Information Systems', NULL),
(N'Software Engineering', NULL),
(N'Computer Engineering', NULL),
(N'Systems and Computer Networks', NULL),
(N'Computer Science', NULL);
GO