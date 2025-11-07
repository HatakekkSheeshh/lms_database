USE [lms_system];
GO

-- Disable identity insert for all tables. DEFAULT but make sure it is off hehe
SET IDENTITY_INSERT [Audit_Log] OFF;
SET IDENTITY_INSERT [Course] OFF;
SET IDENTITY_INSERT [Section] OFF;
SET IDENTITY_INSERT [Platform] OFF;
SET IDENTITY_INSERT [Building] OFF;
SET IDENTITY_INSERT [Submission] OFF;

-- Insert System data
INSERT INTO [System] (System_name, Domain)
VALUES ('LMS', 'https://hcmut-tutor.vercel.app/');

-- Insert Users data
INSERT INTO [Users] (University_ID, First_Name, Last_Name, Email, Phone_Number, [Address], National_ID, System_name)
VALUES 
    (2352402, 'Huy-chan',       'Phan Tien',        'xoai.non@hcmut.edu.vn',                '0999999999', '497 Hoa Hao, District 10, HCMC',               '079200000000', 'LMS'),
    (2353280, 'Tuan-kun',       'Vu Hai',           'tuan.vuhai@hcmut.edu.vn',              '0917672005', '497 Hoa Hao, District 10, HCMC',               '080205001633', 'LMS'),
    (2352022, 'Anh-sama',       'Chu Nguyen Tuan',  'anh.chunguyentuan@hcmut.edu.vn',       '0962037357', 'Vung Tau, HCMC',                               '079200000002', 'LMS'),
    (2352344, 'Hieu-ricon',     'Nguyen Quoc',      'hieu.nguyenronaldojr@hcmut.edu.vn',    '0792107608', '1 Nguyen Quang Bich, Tan Binh District, HCMC', '079205013433', 'LMS'),
    (2353103, 'Thanh-gencon',   'Pham Quang Tien',  'thanh.pham04052005@hcmut.edu.vn',      '0902688812', 'No Info, HCMC',                                '079200000004', 'LMS');


