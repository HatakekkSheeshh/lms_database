# Hướng dẫn nhanh: Kết nối Master Database trong Azure Portal

## Bước 1: Vào SQL Server

1. Từ trang **SQL databases** (trang bạn đang ở)
2. **Click vào server name**: `lms-hcmut` (hyperlink màu xanh)
3. Bạn sẽ vào trang **SQL Server**

## Bước 2: Mở Query Editor

1. Trong menu bên trái, tìm **"Query editor (preview)"**
2. Click vào nó
3. Query editor sẽ mở ra

## Bước 3: Chọn Master Database

1. Ở trên cùng query editor, tìm **dropdown database**
2. Click dropdown (có thể hiển thị "lms_system" hoặc database khác)
3. **Chọn "master"** từ danh sách

## Bước 4: Xác nhận

Chạy query này để xác nhận:
```sql
SELECT DB_NAME() AS CurrentDatabase;
```
Kết quả phải là: `master`

## Bước 5: Chạy Script

1. Mở file `grant_azure_master.sql`
2. Copy toàn bộ nội dung
3. Paste vào query editor
4. Click **"Run"** hoặc nhấn `F5`

---

## Nếu không thấy Query Editor:

### Option A: Dùng nút "Open query"
1. Ở trang SQL databases
2. Click nút **"Open query"** (có icon database) ở thanh trên cùng
3. Chọn database "master" nếu có dropdown

### Option B: Vào database trước
1. Click vào database **"lms_system"**
2. Vào **"Query editor (preview)"**
3. Chuyển database sang "master" bằng dropdown

### Option C: Dùng Azure Data Studio
1. Download Azure Data Studio (nếu chưa có)
2. Tạo connection mới:
   - Server: `lms-hcmut.database.windows.net`
   - Database: **master**
   - Authentication: SQL Login
3. Connect và chạy script

---

## Visual Guide:

```
Azure Portal
└── SQL databases (trang hiện tại)
    └── Click "lms-hcmut" (server name)
        └── SQL Server page
            └── Left menu: "Query editor (preview)"
                └── Query Editor opens
                    └── Dropdown: Select "master"
                        └── Run grant_azure_master.sql
```

