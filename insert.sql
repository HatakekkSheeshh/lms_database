USE [lms_system];
GO

-- Disable identity insert for all tables
SET IDENTITY_INSERT [Course] OFF;
SET IDENTITY_INSERT [Section] OFF;
SET IDENTITY_INSERT [Assessment] OFF;
SET IDENTITY_INSERT [Feedback] OFF;
SET IDENTITY_INSERT [Audit_Log] OFF;
SET IDENTITY_INSERT [Platform] OFF;
SET IDENTITY_INSERT [Building] OFF;
SET IDENTITY_INSERT [Room] OFF;
SET IDENTITY_INSERT [Submission] OFF;
SET IDENTITY_INSERT [Review] OFF;

-- Insert System data
INSERT INTO [System] (System_name, Domain)
VALUES ('BK E-Learning', 'e-learning.hcmut.edu.vn');

-- Insert Users data
INSERT INTO [Users] (University_ID, First_Name, Last_Name, Email, Phone_Number, [Address], National_ID, System_name)
VALUES 
    (100001, 'John', 'Doe', 'john.doe@hcmut.edu.vn', 8401234567, '123 Ly Thuong Kiet, District 10, HCMC', 079123456789, 'BK E-Learning'),
    (100002, 'Jane', 'Smith', 'jane.smith@hcmut.edu.vn', 8409876543, '456 Nguyen Van Cu, District 5, HCMC', 079987654321, 'BK E-Learning'),
    (200001, 'David', 'Wilson', 'david.wilson@hcmut.edu.vn', 8405555555, '789 Le Hong Phong, District 5, HCMC', 079555555555, 'BK E-Learning');

-- Insert Account data
INSERT INTO [Account] (University_ID, [Password])
VALUES 
    (100001, 'hashedpassword123'),
    (100002, 'hashedpassword456'),
    (200001, 'hashedpassword789');

-- Insert Admin data
INSERT INTO [Admin] (University_ID, [Type])
VALUES (100001, 'Coordinator');

-- Insert Student data
INSERT INTO [Student] (University_ID, Major, Current_degree)
VALUES (100002, 'Computer Science', 'Bachelor');

-- Insert Department data
INSERT INTO [Department] (Department_Name, University_ID)
VALUES ('Computer Science and Engineering', 100001);

-- Insert Tutor data
INSERT INTO [Tutor] (University_ID, [Name], Academic_Rank, Details, Issuance_Date, Department_Name)
VALUES (200001, 'Dr. David Wilson', 'Associate Professor', 'PhD in Computer Science', '2020-01-01', 'Computer Science and Engineering');

-- Enable identity insert for Course table
SET IDENTITY_INSERT [Course] ON;
-- Insert Course data
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date)
VALUES (1, 'Database Systems', 4, '2025-09-01');
-- Disable identity insert for Course table
SET IDENTITY_INSERT [Course] OFF;

-- Enable identity insert for Section table
SET IDENTITY_INSERT [Section] ON;
-- Insert Section data
INSERT INTO [Section] (Section_ID, Course_ID, Semester)
VALUES (1, 1, '251');
-- Disable identity insert for Section table
SET IDENTITY_INSERT [Section] OFF;

-- Insert Teaches data
INSERT INTO [Teaches] (Tutor_ID, Section_ID, Course_ID, Role_Specification, [Timestamp])
VALUES (200001, 1, 1, 'Main Lecturer', '2025-09-01T08:00:00');

-- Enable identity insert for Assessment table
SET IDENTITY_INSERT [Assessment] ON;
-- Insert Assessment data
INSERT INTO [Assessment] (Assessment_ID, University_ID, Section_ID, Course_ID, Grade, Registration_Date, Potential_Withdrawal_Date, [Status])
VALUES (1, 100002, 1, 1, 8.5, '2025-09-01', '2025-12-31', 'Approved');
-- Disable identity insert for Assessment table
SET IDENTITY_INSERT [Assessment] OFF;

-- Enable identity insert for Building table
SET IDENTITY_INSERT [Building] ON;
-- Insert Building data
INSERT INTO [Building] (Building_ID)
VALUES (1);
-- Disable identity insert for Building table
SET IDENTITY_INSERT [Building] OFF;

-- Enable identity insert for Room table
SET IDENTITY_INSERT [Room] ON;
-- Insert Room data
INSERT INTO [Room] (Room_ID, Building_ID, Capacity, RoomType)
VALUES (1, 1, 60, 'Lecture');
-- Disable identity insert for Room table
SET IDENTITY_INSERT [Room] OFF;

-- Insert Takes_Place data
INSERT INTO [Takes_Place] (Section_ID, Course_ID, Room_ID, Building_ID)
VALUES (1, 1, 1, 1);

-- Insert Equipment data
INSERT INTO [Equipment] (Equipment, Room_ID, Building_ID, Quantity, Status)
VALUES ('Projector', 1, 1, 1, 'Available');

-- Enable identity insert for Platform table
SET IDENTITY_INSERT [Platform] ON;
-- Insert Platform data
INSERT INTO [Platform] (Platform_ID, Name)
VALUES (1, 'MS Teams');
-- Disable identity insert for Platform table
SET IDENTITY_INSERT [Platform] OFF;

-- Insert Online data
INSERT INTO [Online] (Platform_ID, Section_ID, Course_ID)
VALUES (1, 1, 1);

-- Insert Link data
INSERT INTO [Link] (link, Platform_ID)
VALUES ('https://teams.microsoft.com/course/db-systems', 1);

-- Insert Quiz data
INSERT INTO [Quiz] (University_ID, Section_ID, Course_ID, Assessment_ID, Grading_method, pass_score, Time_limits, 
    Start_Date, End_Date, Responses, completion_status, score, content, types, Weight, Correct_answer)
VALUES (100002, 1, 1, 1, 'Highest Attemp', 5.0, '01:30:00', 
    '2025-10-15T09:00:00', '2025-10-15T10:30:00', 'A, B, C, D', 'Passed', 8.5, 'Midterm Quiz', 'Multiple Choice', 0.3, 'B');

-- Insert Assignment data
INSERT INTO [Assignment] (University_ID, Section_ID, Course_ID, Assessment_ID, MaxScore, 
    accepted_specification, submission_deadline, instructions)
VALUES (100002, 1, 1, 1, 10, 'PDF, DOC', '2025-10-31T23:59:59', 'Submit your database design report');

-- Enable identity insert for Submission table
SET IDENTITY_INSERT [Submission] ON;
-- Insert Submission data
INSERT INTO [Submission] (Submission_No, University_ID, Section_ID, Course_ID, Assessment_ID, 
    accepted_specification, late_flag_indicator, SubmitDate, attached_files, status)
VALUES (1, 100002, 1, 1, 1, 'PDF', 0, '2025-10-30T22:45:00', 'assignment2_report.pdf', 'Submitted');
-- Disable identity insert for Submission table
SET IDENTITY_INSERT [Submission] OFF;

-- Enable identity insert for Review table
SET IDENTITY_INSERT [Review] ON;
-- Insert Review data
INSERT INTO [Review] (Review_ID, Submission_No, University_ID, Score, Comments)
VALUES (1, 1, 200001, 9, 'Excellent work on the database design');
-- Disable identity insert for Review table
SET IDENTITY_INSERT [Review] OFF;

-- Enable identity insert for Feedback table
SET IDENTITY_INSERT [Feedback] ON;
-- Insert Feedback data
INSERT INTO [Feedback] (Feedback_ID, Section_ID, Course_ID, Assessment_ID, University_ID, Feedback_Text)
VALUES (1, 1, 1, 1, 100002, 'The course materials were very helpful');
-- Disable identity insert for Feedback table
SET IDENTITY_INSERT [Feedback] OFF;

-- Enable identity insert for Audit_Log table
SET IDENTITY_INSERT [Audit_Log] ON;
-- Insert Audit_Log data
INSERT INTO [Audit_Log] (LogID, System_name)
VALUES (1, 'BK E-Learning');
-- Disable identity insert for Audit_Log table
SET IDENTITY_INSERT [Audit_Log] OFF;

-- Insert Reference_To data
INSERT INTO [Reference_To] (LogID, University_ID)
VALUES (1, 100002);

GO
