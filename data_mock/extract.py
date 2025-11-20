import pandas as pd
import sys
import os

# Try to import tabula-py (correct package name)
try:
    import tabula
    # Check if it's the correct tabula (tabula-py)
    if not hasattr(tabula, 'read_pdf'):
        # Try alternative import
        try:
            from tabula import read_pdf
        except ImportError:
            print("ERROR: Please install tabula-py package:")
            print("  pip install tabula-py")
            print("  Note: You also need Java installed for tabula-py to work")
            sys.exit(1)
except ImportError:
    print("ERROR: tabula-py package not found!")
    print("Please install it using:")
    print("  pip install tabula-py")
    print("  Note: You also need Java installed for tabula-py to work")
    sys.exit(1)

DEPT_MAPPING = {
    "HTTT":  "Information Systems",
    "CNPM":  "Software Engineering",
    "KTMT":  "Computer Engineering",
    "HT&MMT": "Systems and Computer Networks",
    "KHMT":  "Computer Science",
}

pdf_path = "2025_09_08_DS_CBGD_Share.pdf"

# Check if PDF file exists
if not os.path.exists(pdf_path):
    print(f"ERROR: File '{pdf_path}' not found!")
    print(f"Current directory: {os.getcwd()}")
    sys.exit(1)

print(f"Reading PDF: {pdf_path}")

# đọc tất cả bảng trong các trang (ở đây 1–2)
try:
    if hasattr(tabula, 'read_pdf'):
        tables = tabula.read_pdf(pdf_path, pages="1-2", multiple_tables=True, lattice=True)
    else:
        tables = read_pdf(pdf_path, pages="1-2", multiple_tables=True, lattice=True)
except Exception as e:
    print(f"ERROR reading PDF: {e}")
    print("\nTroubleshooting:")
    print("1. Make sure Java is installed (tabula-py requires Java)")
    print("2. Try installing: pip install tabula-py")
    print("3. Alternative: Use pdfplumber or PyPDF2")
    sys.exit(1)

# Check if tables were extracted
if not tables or len(tables) == 0:
    print("ERROR: No tables found in PDF!")
    print("Try adjusting the pages parameter or check PDF format")
    sys.exit(1)

print(f"Found {len(tables)} table(s) in PDF")

# gộp các bảng lại (nếu mỗi trang là 1 bảng)
df = pd.concat(tables, ignore_index=True)

print(f"\nExtracted {len(df)} rows")
print(f"Columns found: {list(df.columns)}")

# chuẩn hoá tên cột (tùy file, có thể hơi khác; in df.columns để kiểm tra)
# thường: ['STT','Bộ môn','MSCB','Họ lót','Tên','Email công vụ','Ghi chú']
# Check column count and adjust if needed
if len(df.columns) >= 6:
    df.columns = ["stt", "department_raw", "university_id",
                  "last_name", "first_name", "email", "note"] if len(df.columns) == 7 else \
                 ["stt", "department_raw", "university_id",
                  "last_name", "first_name", "email"]
else:
    print(f"WARNING: Unexpected number of columns ({len(df.columns)})")
    print("Please check the PDF structure and adjust column mapping")
    print(df.head())
    sys.exit(1)

# map bộ môn sang tiếng Anh
df["department_name"] = df["department_raw"].map(DEPT_MAPPING)

# Check for unmapped departments
unmapped = df[df["department_name"].isna()]["department_raw"].unique()
if len(unmapped) > 0:
    print(f"\nWARNING: Unmapped departments found: {unmapped}")
    print("Please add them to DEPT_MAPPING if needed")

# chọn đúng cột cần
result = df[["department_name", "university_id",
             "first_name", "last_name", "email"]]

# Remove rows with missing essential data
result = result.dropna(subset=["university_id", "first_name", "last_name"])

# lưu ra CSV
output_file = "lecturers_mapped.csv"
result.to_csv(output_file, index=False, encoding="utf-8-sig")

print(f"\n✓ Successfully extracted {len(result)} records")
print(f"✓ Saved to: {output_file}")
print("\nFirst 5 rows:")
print(result.head())
