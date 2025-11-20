# Azure SQL Database Setup Instructions

## Important: Azure SQL Database requires 2-step setup

In Azure SQL Database, `CREATE LOGIN` must be executed in the **master** database, not in your user database.

## Step-by-Step Setup:

### Step 1: Create Logins in Master Database

1. **Connect DIRECTLY to master database**
   - Server: `[your-server].database.windows.net`
   - Authentication: SQL Server Authentication
   - Login: Your admin account (with server admin role)
   - **IMPORTANT:** In connection properties, set Database to **master**
   - **DO NOT** use `USE [master]` statement - connect directly to master database

2. **Run the script:**
   ```
   security/grant_azure_master.sql
   ```
   
   **Note:** The script will verify you're in master database and show an error if not.

3. **Expected output:**
   ```
   Login student_login created successfully.
   Login tutor_login created successfully.
   ```

### Step 2: Create Users and Grant Permissions in lms_system Database

1. **Switch to lms_system database**
   - Still connected to the same server
   - Change database to: **lms_system**

2. **Run the script:**
   ```
   security/grant.sql
   ```

3. **Expected output:**
   ```
   Database user student created successfully.
   Database user tutor created successfully.
   [All views, functions, and permissions created]
   ```

## Troubleshooting:

### Error: "User must be in the master database"
- **Cause:** Trying to CREATE LOGIN in user database
- **Solution:** Run `grant_azure_master.sql` in **master** database first

### Error: "Cannot find the user 'student'"
- **Cause:** Database user was not created (login doesn't exist)
- **Solution:** 
  1. Verify logins exist: Run in master database: `SELECT * FROM sys.sql_logins WHERE name IN ('student_login', 'tutor_login');`
  2. If logins don't exist, run `grant_azure_master.sql` in master database
  3. Then run `grant.sql` in lms_system database

### Error: "Login failed for user"
- **Cause:** Login exists but password is incorrect
- **Solution:** Default passwords are:
  - `student_login`: `Student@123`
  - `tutor_login`: `Tutor@123`

## Quick Reference:

| Script | Database | Purpose |
|--------|----------|---------|
| `grant_azure_master.sql` | **master** | Create logins |
| `grant.sql` | **lms_system** | Create users, views, grant permissions |

## Verification:

After setup, verify in lms_system database:

```sql
-- Check users exist
SELECT name, type_desc FROM sys.database_principals 
WHERE name IN ('student', 'tutor');

-- Check views exist
SELECT name FROM sys.views 
WHERE name LIKE 'vw_%';

-- Test login (connect as student_login)
-- Then run: EXEC sp_SetUserContext @University_ID = 2211073, @Password = 'user2211073';
```

