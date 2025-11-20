import json
import os

# Read JSON file
json_path = "tutor_id.json"
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Check for duplicate University_IDs
seen_ids = {}
duplicates = []
for i, tutor in enumerate(data):
    uid = tutor['university_id']
    if uid in seen_ids:
        duplicates.append((uid, seen_ids[uid], i))
    else:
        seen_ids[uid] = i

if duplicates:
    print(f"WARNING: Found {len(duplicates)} duplicate University_ID(s):")
    for uid, first_idx, dup_idx in duplicates:
        print(f"  University_ID {uid}: appears at index {first_idx} and {dup_idx}")

# Remove duplicates - keep first occurrence
unique_data = []
seen_uids = set()
for tutor in data:
    uid = tutor['university_id']
    if uid not in seen_uids:
        unique_data.append(tutor)
        seen_uids.add(uid)
    else:
        print(f"  Skipping duplicate: University_ID {uid}")

print(f"Processing {len(unique_data)} unique tutors (removed {len(data) - len(unique_data)} duplicates)")

# Generate SQL for Users table
users_values = []
tutor_values = []

for tutor in unique_data:
    university_id = int(tutor['university_id'])
    first_name = tutor['first_name'].replace("'", "''")  # Escape single quotes
    last_name = tutor['last_name'].replace("'", "''")
    email = tutor['email'].replace("'", "''")
    department_name = tutor['department_name'].replace("'", "''")
    
    # National_ID: pad with zeros to 12 digits
    national_id = f"00000000{university_id:04d}"[-12:]
    
    # Users table
    users_values.append(
        f"    ({university_id}, N'{first_name}', N'{last_name}', N'{email}', N'{national_id}')"
    )
    
    # Tutor table
    # Name = Last_Name + ' ' + First_Name
    full_name = f"{last_name} {first_name}".replace("'", "''")
    
    # Generate default values for missing fields
    # Academic_Rank: default to 'Lecturer'
    academic_rank = "Lecturer"
    
    # Details: based on department
    details_map = {
        "Computer Engineering": "Computer Engineering specialist",
        "Computer Science": "Computer Science specialist",
        "Software Engineering": "Software Engineering specialist",
        "Information Systems": "Information Systems specialist",
        "Systems and Computer Networks": "Systems and Computer Networks specialist"
    }
    details = details_map.get(department_name, "Faculty member")
    
    # Issuance_Date: default to a recent date (can be adjusted)
    issuance_date = "2020-01-01"
    
    tutor_values.append(
        f"    ({university_id}, N'{full_name}', N'{academic_rank}', N'{details}', '{issuance_date}', N'{department_name}')"
    )

# Generate SQL script
sql_lines = [
    "USE [lms_system];",
    "GO",
    "",
    "/* =======================",
    "   1. Upsert vào bảng Users",
    "   ======================= */",
    "",
    "MERGE [Users] AS target",
    "USING (",
    "    SELECT * FROM (VALUES"
]

# Add Users VALUES with proper formatting
for i, val in enumerate(users_values):
    if i < len(users_values) - 1:
        sql_lines.append(val + ",")
    else:
        sql_lines.append(val)

sql_lines.extend([
    "    ) AS t(University_ID, First_Name, Last_Name, Email, National_ID)",
    ") AS src (University_ID, First_Name, Last_Name, Email, National_ID)",
    "ON target.University_ID = src.University_ID",
    "WHEN MATCHED THEN",
    "    UPDATE SET",
    "        First_Name = src.First_Name,",
    "        Last_Name  = src.Last_Name,",
    "        Email      = src.Email,",
    "        National_ID = src.National_ID",
    "WHEN NOT MATCHED BY TARGET THEN",
    "    INSERT (University_ID, First_Name, Last_Name, Email, National_ID)",
    "    VALUES (src.University_ID, src.First_Name, src.Last_Name, src.Email, src.National_ID);",
    "GO",
    "",
    "/* =======================",
    "   2. Upsert vào bảng Tutor",
    "   ======================= */",
    "",
    "MERGE [Tutor] AS target",
    "USING (",
    "    SELECT * FROM (VALUES"
])

# Add Tutor VALUES with proper formatting
for i, val in enumerate(tutor_values):
    if i < len(tutor_values) - 1:
        sql_lines.append(val + ",")
    else:
        sql_lines.append(val)

sql_lines.extend([
    "    ) AS t(University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)",
    ") AS src (University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)",
    "ON target.University_ID = src.University_ID",
    "WHEN MATCHED THEN",
    "    UPDATE SET",
    "        [Name]         = src.[Name],",
    "        Academic_Rank  = src.Academic_Rank,",
    "        [Details]      = src.[Details],",
    "        Issuance_Date  = src.Issuance_Date,",
    "        Department_Name = src.Department_Name",
    "WHEN NOT MATCHED BY TARGET THEN",
    "    INSERT (University_ID, [Name], Academic_Rank, [Details], Issuance_Date, Department_Name)",
    "    VALUES (src.University_ID, src.[Name], src.Academic_Rank, src.[Details], src.Issuance_Date, src.Department_Name);",
    "GO",
    "",
    f"PRINT 'Tutor data updated successfully.';",
    f"PRINT 'Total tutors: ' + CAST({len(unique_data)} AS NVARCHAR(10));",
    "GO"
])

sql_content = "\n".join(sql_lines)

# Write to file
output_file = "../fix_table/tutor.sql"
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(sql_content)

print(f"Generated SQL script: {output_file}")
print(f"Total tutors: {len(unique_data)}")

