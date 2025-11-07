# LMS System Database Setup Guide

Complete guide to set up the LMS (Learning Management System) database.

## Prerequisites

- SQL Server 2019 or later
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Permissions to create databases and tables

## Step-by-Step Setup

### Step 1: Create Database

Run the `create_database.sql` file to create the `lms_system` database with Vietnamese collation:

```sql
-- File: create_database.sql
-- Creates database with Vietnamese_100_CI_AS collation for Vietnamese language support
```

**How to run:**
1. Open SQL Server Management Studio (SSMS) or Azure Data Studio
2. Connect to your SQL Server instance
3. Open the `create_database.sql` file
4. Press F5 or click "Execute" to run the script

**Result:** The `lms_system` database will be created with `Vietnamese_100_CI_AS` collation

---

### Step 2: Create Tables

Run the `database.sql` file to create all tables in the database:

```sql
-- File: database.sql
-- Creates all tables: Users, Account, Admin, Student, Tutor, Course, Section, etc.
```

**How to run:**
1. Open the `database.sql` file
2. Press F5 or click "Execute" to run the script

**Notes:**
- The script will automatically DROP and recreate all tables
- All text columns have been changed to `NVARCHAR` for Vietnamese language support
- `Vietnamese_100_CI_AS` collation is applied to text columns

**Result:** All tables will be created with complete structure

---

### Step 3: Insert Data

Run the `insert/insert_users.sql` file to insert user data:

```sql
-- File: insert/insert_users.sql
-- Inserts 464 users from user_db.json with N prefix for Unicode
```

**How to run:**
1. Open the `insert/insert_users.sql` file
2. Press F5 or click "Execute" to run the script

**Notes:**
- The file uses prefix `N` for all Unicode strings to support Vietnamese characters
- Example: `N'Nguyễn'` instead of `'Nguyễn'`

**Result:** 464 users will be inserted into the `Users` table

---

### Step 4: Verify

Run the following queries to verify the data:

#### 4.1. Check user count:
```sql
USE [lms_system];
GO

SELECT COUNT(*) AS TotalUsers
FROM [Users];
```

#### 4.2. View user data (check Vietnamese characters):
```sql
SELECT TOP 10 
    University_ID,
    First_Name,
    Last_Name,
    Email,
    Phone_Number,
    [Address]
FROM [Users]
ORDER BY University_ID;
```

#### 4.3. Check collation:
```sql
-- Check database collation
SELECT name, collation_name 
FROM sys.databases 
WHERE name = 'lms_system';

-- Check column collation
SELECT COLUMN_NAME, DATA_TYPE, COLLATION_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users'
AND COLUMN_NAME IN ('First_Name', 'Last_Name', 'Address');
```

---

## Quick Start

To run everything at once:

1. **Create database:**
   ```sql
   -- Run: create_database.sql
   ```

2. **Create tables:**
   ```sql
   -- Run: database.sql
   ```

3. **Insert data:**
   ```sql
   -- Run: insert/insert_users.sql
   ```

4. **Verify:**
   ```sql
   SELECT COUNT(*) FROM [Users];
   ```

---

## Troubleshooting

### Issue: Vietnamese characters display as question marks (?)

**Cause:**
- Data was inserted before changing to NVARCHAR
- INSERT statements don't use prefix `N`

**Solution:**
1. Delete old data:
   ```sql
   DELETE FROM [Users];
   ```

2. Run `insert/insert_users.sql` again (already has prefix `N`)

### Issue: Foreign key constraint error

**Cause:**
- Inserting data before creating related tables

**Solution:**
- Make sure to run `database.sql` before inserting data

### Issue: Database already exists

**Solution:**
- The `create_database.sql` file will automatically DROP the old database if it exists

---

## File Structure

```
database_assignment/
├── create_database.sql      # Create lms_system database
├── database.sql             # Create all tables
├── insert/
│   └── insert_users.sql     # Insert user data
├── data_mock/
│   └── user_db.json         # User data (JSON)
├── security/
│   └── security.sql         # Security scripts
└── view/
    └── view_table.sql        # View data scripts
```

---

## Database Schema Overview

### Main Tables:
- **Users**: User information (supports Vietnamese)
- **Account**: Login accounts
- **Student**: Student information
- **Tutor**: Tutor/Instructor information
- **Course**: Courses
- **Section**: Course sections
- **Assessment**: Assessments
- **Assignment**: Assignments
- **Quiz**: Quizzes
- **Submission**: Submissions

---

## Notes

- All text columns have been changed to `NVARCHAR` for Unicode support
- Database collation: `Vietnamese_100_CI_AS`
- INSERT statements use prefix `N` for Unicode strings
- Sample data: 464 users from `data_mock/user_db.json`

---

## Support

If you encounter issues, check:
1. SQL Server version (should use 2019+)
2. Database collation must be `Vietnamese_100_CI_AS`
3. All text columns must be `NVARCHAR`
4. INSERT statements must use prefix `N`
