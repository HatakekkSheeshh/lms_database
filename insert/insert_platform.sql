USE [lms_system];
GO

-- Delete child records first (both Platform_Link and Online reference Platform)
DELETE FROM [Online];
GO

DELETE FROM [Platform_Link];
GO

DELETE FROM [Platform];
GO

-- Reset the identity seed to start from 0 again
DBCC CHECKIDENT ('Platform', RESEED, -1);
GO

INSERT INTO [Platform] ([Name]) VALUES
(N'Microsoft Teams'),
(N'Google Meet'),
(N'Zoom Meeting'),
(N'BK-eLearning (Moodle)'),
(N'Website Khoa');
GO