# Hướng dẫn Test Student Login

## Cách chạy test:

### Cách 1: Sử dụng SQL Server Management Studio (SSMS)

1. **Kết nối với student_login:**
   - Server: `[your_server_name]`
   - Authentication: SQL Server Authentication
   - Login: `student_login`
   - Password: `Student@123`

2. **Chạy script test:**
   - Mở file `test_student_login.sql`
   - Nhấn F5 hoặc click "Execute"

### Cách 2: Sử dụng Azure Data Studio

1. **Tạo connection mới:**
   - Connection type: Microsoft SQL Server
   - Server: `[your_server_name]`
   - Authentication type: SQL Login
   - Username: `student_login`
   - Password: `Student@123`

2. **Chạy script:**
   - Mở file `test_student_login.sql`
   - Chạy toàn bộ script

### Cách 3: Sử dụng sqlcmd (Command Line)

```bash
sqlcmd -S [server_name] -U student_login -P Student@123 -d lms_system -i test_student_login.sql
```

## Kết quả mong đợi:

1. **sp_SetUserContext** sẽ set:
   - University_ID = 2211073
   - User_Type = 'Student'

2. **Các views sẽ chỉ hiển thị:**
   - Assessment: chỉ records có University_ID = 2211073
   - Feedback: chỉ records có University_ID = 2211073
   - Submission: chỉ records có University_ID = 2211073
   - Quiz: chỉ records có University_ID = 2211073

3. **Course table:** hiển thị tất cả courses (không filter)

## Lưu ý:

- Đảm bảo đã chạy `insert_account.sql` để tạo password cho user 2211073
- Đảm bảo đã chạy `security/grant.sql` để setup permissions
- Nếu không có dữ liệu, các views sẽ trả về empty result set

## Troubleshooting:

**Lỗi: "Invalid password"**
- Kiểm tra password trong bảng Account: `SELECT * FROM Account WHERE University_ID = 2211073;`
- Password phải là: `user2211073`

**Lỗi: "User is not a Student or Tutor"**
- Kiểm tra user có trong bảng Student: `SELECT * FROM Student WHERE University_ID = 2211073;`

**Views trả về empty:**
- Kiểm tra có dữ liệu trong Assessment table: `SELECT * FROM Assessment WHERE University_ID = 2211073;`
- Kiểm tra SESSION_CONTEXT: `SELECT SESSION_CONTEXT(N'University_ID') AS University_ID;`

