# Hướng dẫn Extract dữ liệu từ PDF

## Yêu cầu:

1. **Python 3.7+**
2. **Java** (bắt buộc cho tabula-py)
   - Download: https://www.java.com/download/
   - Verify: `java -version`

## Cài đặt:

```bash
# Cài đặt packages
pip install -r requirements.txt

# Hoặc cài đặt thủ công:
pip install pandas tabula-py
```

## Chạy script:

```bash
cd data_mock
python extract.py
```

## Output:

Script sẽ tạo file `lecturers_mapped.csv` với các cột:
- `department_name`: Tên department (tiếng Anh)
- `university_id`: Mã số cán bộ
- `first_name`: Tên
- `last_name`: Họ
- `email`: Email

## Troubleshooting:

### Lỗi: "module 'tabula' has no attribute 'read_pdf'"
**Giải pháp:**
```bash
pip uninstall tabula
pip install tabula-py
```

### Lỗi: "Java not found"
**Giải pháp:**
- Cài đặt Java JDK hoặc JRE
- Thêm Java vào PATH
- Restart terminal/IDE

### Lỗi: "No tables found in PDF"
**Giải pháp:**
- Kiểm tra PDF có phải là bảng không
- Thử điều chỉnh tham số `pages` trong script
- Thử dùng `lattice=False` thay vì `lattice=True`

## Alternative: Dùng pdfplumber (không cần Java)

Nếu tabula-py không hoạt động, có thể dùng pdfplumber:

```bash
pip install pdfplumber pandas
```

Sau đó sửa script để dùng pdfplumber thay vì tabula.

