USE [lms_system];
GO

/* =======================
   1. Upsert vào bảng Users
   ======================= */

MERGE [Users] AS target
USING (
    SELECT * FROM (VALUES
    (4202, N'Ân', N'Nguyễn Thiên', N'ngthienan.cse@hcmut.edu.vn', N'000000004202'),
    (4320, N'Anh', N'Phạm Kiều Nhật', N'anhpkn@hcmut.edu.vn', N'000000004320'),
    (2603, N'Anh', N'Phạm Hoàng', N'anhpham@hcmut.edu.vn', N'000000002603'),
    (3778, N'Anh', N'Trần Tuấn', N'trtanh@hcmut.edu.vn', N'000000003778'),
    (2883, N'Anh', N'Trương Tuấn', N'anhtt@hcmut.edu.vn', N'000000002883'),
    (4351, N'Bách', N'Lê Xuân', N'lexuanbach@hcmut.edu.vn', N'000000004351'),
    (4319, N'Bình', N'Võ Tuấn', N'binh@hcmut.edu.vn', N'000000004319'),
    (2919, N'Châu', N'Võ Thị Ngọc', N'chauvtn@hcmut.edu.vn', N'000000002919'),
    (2889, N'Chi', N'Trương Quỳnh', N'tqchi@hcmut.edu.vn', N'000000002889'),
    (4297, N'Công', N'Nguyễn Thành', N'congnguyen@hcmut.edu.vn', N'000000004297'),
    (2765, N'Cường', N'Phạm Quốc', N'cuongpham@hcmut.edu.vn', N'000000002765'),
    (2415, N'Dat', N'Nguyễn Cao', N'dat@hcmut.edu.vn', N'000000002415'),
    (3726, N'Đăng', N'Diệp Thanh', N'dang@hcmut.edu.vn', N'000000003726'),
    (4267, N'Đẳng', N'Lê Bình', N'binhdang@hcmut.edu.vn', N'000000004267'),
    (4340, N'Đức', N'Dương Huỳnh Anh', N'anhducduonghuynh@hcmut.edu.vn', N'000000004340'),
    (3682, N'Dũng', N'Nguyễn Đức', N'nddung@hcmut.edu.vn', N'000000003682'),
    (3446, N'Duy', N'Nguyễn Phương', N'pdnguyen@hcmut.edu.vn', N'000000003446'),
    (2607, N'Duy', N'Phan Đình Thế', N'duypdt@hcmut.edu.vn', N'000000002607'),
    (3904, N'Duy', N'Trần Ngọc Bảo', N'duytnb@hcmut.edu.vn', N'000000003904'),
    (4272, N'Duy', N'Trần Nguyễn Minh', N'tnmduy@hcmut.edu.vn', N'000000004272'),
    (3591, N'Giang', N'Bùi Xuân', N'xuangiang@hcmut.edu.vn', N'000000003591'),
    (4356, N'Giang', N'Trịnh Văn', N'van-giang.trinh@hcmut.edu.vn', N'000000004356'),
    (4278, N'Hiền', N'Lương Minh', N'minhhienluongbk@hcmut.edu.vn', N'000000004278'),
    (3718, N'Hiếu', N'Nguyễn Hữu', N'nguyenhuuhieu@hcmut.edu.vn', N'000000003718'),
    (4206, N'Hiếu', N'Phan Trung', N'hieupt@hcmut.edu.vn', N'000000004206'),
    (1742, N'Hoài', N'Trần Văn', N'hoai@hcmut.edu.vn', N'000000001742'),
    (2609, N'Hùng', N'Nguyễn Quang', N'nqhung@hcmut.edu.vn', N'000000002609'),
    (3282, N'Hùng', N'Võ Thanh', N'vthung@hcmut.edu.vn', N'000000003282'),
    (4141, N'Huy', N'Trần', N'tranhuy@hcmut.edu.vn', N'000000004141'),
    (4350, N'Khôi', N'Nguyễn Tuấn', N'tuankhoin@hcmut.edu.vn', N'000000004350'),
    (3634, N'Khương', N'Nguyễn An', N'nakhuong@hcmut.edu.vn', N'000000003634'),
    (4343, N'Lân', N'Trương Vĩnh', N'lantv@hcmut.edu.vn', N'000000004343'),
    (2921, N'Lai', N'Nguyễn Lê Duy', N'lai@hcmut.edu.vn', N'000000002921'),
    (4269, N'Lộc', N'Nguyễn Thành', N'loknguyen@hcmut.edu.vn', N'000000004269'),
    (4322, N'Long', N'Tôn Huỳnh', N'huynhlong.ton@hcmut.edu.vn', N'000000004322'),
    (4318, N'Minh', N'Nguyễn Quốc', N'minhnguyen@hcmut.edu.vn', N'000000004318'),
    (1528, N'Minh', N'Nguyễn Xuân', N'minh@hcmut.edu.vn', N'000000001528'),
    (3717, N'Minh', N'Trương Thị Thái', N'thaiminh@hcmut.edu.vn', N'000000003717'),
    (1748, N'Nam', N'Thoại', N'namthoai@hcmut.edu.vn', N'000000001748'),
    (4077, N'Nghị', N'Huỳnh Phúc', N'nghihp@hcmut.edu.vn', N'000000004077'),
    (2890, N'Nguyệt', N'Trần Thị Quế', N'ttqnguyet@hcmut.edu.vn', N'000000002890'),
    (3777, N'Nhân', N'Lê Trọng', N'trongnhanle@hcmut.edu.vn', N'000000003777'),
    (3178, N'Nhân', N'Phan Trọng', N'nhanpt@hcmut.edu.vn', N'000000003178'),
    (4282, N'Phát', N'Trần Trương Tuấn', N'phatttt@hcmut.edu.vn', N'000000004282'),
    (1733, N'Phùng', N'Nguyễn Hứa', N'nhphung@hcmut.edu.vn', N'000000001733'),
    (4321, N'Quân', N'Thi Khắc', N'tkquan@hcmut.edu.vn', N'000000004321'),
    (1964, N'Quang', N'Trần Minh', N'quangtran@hcmut.edu.vn', N'000000001964'),
    (1995, N'Sách', N'Lê Thành', N'ltsach@hcmut.edu.vn', N'000000001995'),
    (2715, N'Sơn', N'Trần Giang', N'tgson@hcmut.edu.vn', N'000000002715'),
    (4339, N'Sỹ', N'Phan Văn', N'syphan.cse@hcmut.edu.vn', N'000000004339'),
    (4271, N'Tâm', N'Nguyễn Minh', N'tam.nguyen272@hcmut.edu.vn', N'000000004271'),
    (4075, N'Tài', N'Trần Hồng', N'thtai@hcmut.edu.vn', N'000000004075'),
    (4258, N'Thái', N'Phạm Công', N'thaipham@hcmut.edu.vn', N'000000004258'),
    (3048, N'Thái', N'Nguyễn Đức', N'ngdthai@hcmut.edu.vn', N'000000003048'),
    (1966, N'Thắng', N'Bùi Hoài', N'bhthang@hcmut.edu.vn', N'000000001966'),
    (3972, N'Thanh', N'Hoàng Lê Hải', N'thanhhoang@hcmut.edu.vn', N'000000003972'),
    (3183, N'Thảo', N'Nguyễn Thị Ái', N'thaonguyen@hcmut.edu.vn', N'000000003183'),
    (3633, N'Thìn', N'Nguyễn Mạnh', N'nmthin@hcmut.edu.vn', N'000000003633'),
    (1897, N'Thịnh', N'Trần Ngọc', N'tnthinh@hcmut.edu.vn', N'000000001897'),
    (3444, N'Thịnh', N'Vương Bá', N'vbthinh@hcmut.edu.vn', N'000000003444'),
    (4336, N'Thống', N'Huỳnh Văn', N'vthuynh@hcmut.edu.vn', N'000000004336'),
    (2416, N'Thơ', N'Quản Thành', N'qttho@hcmut.edu.vn', N'000000002416'),
    (3383, N'Thu', N'Lê Thị Bảo', N'thule@hcmut.edu.vn', N'000000003383'),
    (3185, N'Thuận', N'Lê Đình', N'thuanle@hcmut.edu.vn', N'000000003185'),
    (4305, N'Tin', N'Dương Đức', N'ddtin@hcmut.edu.vn', N'000000004305'),
    (4143, N'Toàn', N'Mai Xuân', N'mxtoan@hcmut.edu.vn', N'000000004143'),
    (3744, N'Trang', N'Lê Hồng', N'lhtrang@hcmut.edu.vn', N'000000003744'),
    (1690, N'Trí', N'Nguyễn Cao', N'caotri@hcmut.edu.vn', N'000000001690'),
    (3710, N'Trung', N'Mai Đức', N'mdtrung@hcmut.edu.vn', N'000000003710'),
    (4352, N'Tú', N'Vũ Ngọc', N'tuvn@hcmut.edu.vn', N'000000004352'),
    (3379, N'Tùng', N'Nguyễn Thanh', N'thanhtung@hcmut.edu.vn', N'000000003379'),
    (3332, N'Vân', N'Lê Thanh', N'ltvan@hcmut.edu.vn', N'000000003332'),
    (2178, N'Vũ', N'Phạm Trần', N'ptvu@hcmut.edu.vn', N'000000002178'),
    (1967, N'Vững', N'Đoàn Minh', N'vungdm@hcmut.edu.vn', N'000000001967')
    ) AS t(University_ID, First_Name, Last_Name, Email, National_ID)
) AS src (University_ID, First_Name, Last_Name, Email, National_ID)
ON target.University_ID = src.University_ID
WHEN MATCHED THEN
    UPDATE SET
        First_Name = src.First_Name,
        Last_Name  = src.Last_Name,
        Email      = src.Email,
        National_ID = src.National_ID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (University_ID, First_Name, Last_Name, Email, National_ID)
    VALUES (src.University_ID, src.First_Name, src.Last_Name, src.Email, src.National_ID);
GO

/* =======================
   2. Upsert vào bảng Tutor
   ======================= */

MERGE [Tutor] AS target
USING (
    SELECT * FROM (VALUES
    (4202, N'Nguyễn Thiên Ân', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (4320, N'Phạm Kiều Nhật Anh', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (2603, N'Phạm Hoàng Anh', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (3778, N'Trần Tuấn Anh', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (2883, N'Trương Tuấn Anh', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (4351, N'Lê Xuân Bách', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (4319, N'Võ Tuấn Bình', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (2919, N'Võ Thị Ngọc Châu', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (2889, N'Trương Quỳnh Chi', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (4297, N'Nguyễn Thành Công', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (2765, N'Phạm Quốc Cường', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (2415, N'Nguyễn Cao Dat', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (3726, N'Diệp Thanh Đăng', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (4267, N'Lê Bình Đẳng', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4340, N'Dương Huỳnh Anh Đức', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (3682, N'Nguyễn Đức Dũng', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (3446, N'Nguyễn Phương Duy', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (2607, N'Phan Đình Thế Duy', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (3904, N'Trần Ngọc Bảo Duy', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4272, N'Trần Nguyễn Minh Duy', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (3591, N'Bùi Xuân Giang', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (4356, N'Trịnh Văn Giang', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4278, N'Lương Minh Hiền', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (3718, N'Nguyễn Hữu Hiếu', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (4206, N'Phan Trung Hiếu', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (1742, N'Trần Văn Hoài', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (2609, N'Nguyễn Quang Hùng', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (3282, N'Võ Thanh Hùng', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4141, N'Trần Huy', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4350, N'Nguyễn Tuấn Khôi', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (3634, N'Nguyễn An Khương', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4343, N'Trương Vĩnh Lân', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (2921, N'Nguyễn Lê Duy Lai', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (4269, N'Nguyễn Thành Lộc', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (4322, N'Tôn Huỳnh Long', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (4318, N'Nguyễn Quốc Minh', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (1528, N'Nguyễn Xuân Minh', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (3717, N'Trương Thị Thái Minh', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (1748, N'Thoại Nam', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (4077, N'Huỳnh Phúc Nghị', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (2890, N'Trần Thị Quế Nguyệt', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (3777, N'Lê Trọng Nhân', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (3178, N'Phan Trọng Nhân', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (4282, N'Trần Trương Tuấn Phát', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (1733, N'Nguyễn Hứa Phùng', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4321, N'Thi Khắc Quân', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (1964, N'Trần Minh Quang', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (1995, N'Lê Thành Sách', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (2715, N'Trần Giang Sơn', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4339, N'Phan Văn Sỹ', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (4271, N'Nguyễn Minh Tâm', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (4075, N'Trần Hồng Tài', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4258, N'Phạm Công Thái', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (3048, N'Nguyễn Đức Thái', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (1966, N'Bùi Hoài Thắng', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (3972, N'Hoàng Lê Hải Thanh', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (3183, N'Nguyễn Thị Ái Thảo', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (3633, N'Nguyễn Mạnh Thìn', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (1897, N'Trần Ngọc Thịnh', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering'),
    (3444, N'Vương Bá Thịnh', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4336, N'Huỳnh Văn Thống', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (2416, N'Quản Thành Thơ', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (3383, N'Lê Thị Bảo Thu', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (3185, N'Lê Đình Thuận', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (4305, N'Dương Đức Tin', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (4143, N'Mai Xuân Toàn', N'Lecturer', N'Computer Science specialist', '2020-01-01', N'Computer Science'),
    (3744, N'Lê Hồng Trang', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (1690, N'Nguyễn Cao Trí', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (3710, N'Mai Đức Trung', N'Lecturer', N'Software Engineering specialist', '2020-01-01', N'Software Engineering'),
    (4352, N'Vũ Ngọc Tú', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (3379, N'Nguyễn Thanh Tùng', N'Lecturer', N'Information Systems specialist', '2020-01-01', N'Information Systems'),
    (3332, N'Lê Thanh Vân', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (2178, N'Phạm Trần Vũ', N'Lecturer', N'Systems and Computer Networks specialist', '2020-01-01', N'Systems and Computer Networks'),
    (1967, N'Đoàn Minh Vững', N'Lecturer', N'Computer Engineering specialist', '2020-01-01', N'Computer Engineering')
    ) AS t(University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)
) AS src (University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)
ON target.University_ID = src.University_ID
WHEN MATCHED THEN
    UPDATE SET
        [Name]         = src.[Name],
        Academic_Rank  = src.Academic_Rank,
        [Details]      = src.[Details],
        Issuance_Date  = src.Issuance_Date,
        Department_Name = src.Department_Name
WHEN NOT MATCHED BY TARGET THEN
    INSERT (University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)
    VALUES (src.University_ID, src.[Name], src.Academic_Rank, src.[Details], src.Issuance_Date, src.Department_Name);
GO


UPDATE [Department] SET University_ID = 1528 WHERE Department_Name = N'Computer Science'; 
UPDATE [Department] SET University_ID = 1966 WHERE Department_Name = N'Software Engineering'; 
UPDATE [Department] SET University_ID = 1964 WHERE Department_Name = N'Information Systems'; 
UPDATE [Department] SET University_ID = 2603 WHERE Department_Name = N'Computer Engineering'; 
UPDATE [Department] SET University_ID = 1748 WHERE Department_Name = N'Systems and Computer Networks'; 
GO

PRINT 'Tutor data updated successfully.';
PRINT 'Total tutors: ' + CAST(74 AS NVARCHAR(10));
GO