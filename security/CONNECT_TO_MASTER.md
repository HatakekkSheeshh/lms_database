# How to Connect to Master Database in Azure SQL Database

## Method 1: Azure Portal Query Editor (Current Interface)

### Steps:
1. **Navigate to your SQL Server:**
   - Go to Azure Portal
   - Find your SQL Server resource (e.g., `lms-hcmut`)
   - Click on it

2. **Open Query Editor:**
   - In the left menu, click **"Query editor (preview)"**
   - You should see the query editor interface

3. **Switch to Master Database:**
   - Look for a **database dropdown** at the top of the query editor
   - It might show "lms_system" currently
   - Click the dropdown and select **"master"**
   - If you don't see a dropdown:
     - Click **"+ New Query"** button
     - In the new query, you should be able to select database

4. **Verify Connection:**
   - Run this query to verify:
   ```sql
   SELECT DB_NAME() AS CurrentDatabase;
   ```
   - Should return: `master`

5. **Run the Script:**
   - Now run `grant_azure_master.sql` in this connection

---

## Method 2: Azure Data Studio (Recommended)

### Steps:
1. **Open Azure Data Studio**

2. **Create New Connection:**
   - Click **"New Connection"** or press `Ctrl+Shift+N`
   - Fill in connection details:
     ```
     Connection type: Microsoft SQL Server
     Server: [your-server].database.windows.net
     Authentication type: SQL Login
     User name: [your-admin-username]
     Password: [your-admin-password]
     Database: master  ← IMPORTANT: Select "master" here
     ```

3. **Connect:**
   - Click **"Connect"**
   - You should now be connected to master database

4. **Verify:**
   - Run: `SELECT DB_NAME();`
   - Should return: `master`

5. **Run Script:**
   - Open `grant_azure_master.sql`
   - Execute it

---

## Method 3: SQL Server Management Studio (SSMS)

### Steps:
1. **Open SSMS**

2. **Connect to Server:**
   - Server name: `[your-server].database.windows.net`
   - Authentication: **SQL Server Authentication**
   - Login: `[your-admin-username]`
   - Password: `[your-admin-password]`

3. **Set Database:**
   - Click **"Options >>"** button
   - Go to **"Connection Properties"** tab
   - Under **"Connect to database"**, select **"master"**
   - Click **"Connect"**

4. **Verify:**
   - In Object Explorer, you should see you're connected to master
   - Or run: `SELECT DB_NAME();`

5. **Run Script:**
   - Open `grant_azure_master.sql`
   - Execute it

---

## Quick Verification Query

After connecting, run this to verify you're in master:

```sql
SELECT 
    DB_NAME() AS CurrentDatabase,
    CASE 
        WHEN DB_NAME() = 'master' THEN '✓ Correct - You are in master database'
        ELSE '✗ ERROR - You are NOT in master database!'
    END AS Status;
```

---

## Troubleshooting

### Problem: Can't see database dropdown in Azure Portal
**Solution:**
- Try clicking **"+ New Query"** button
- The new query window should allow database selection
- Or use Azure Data Studio instead (easier)

### Problem: "User must be in the master database" error
**Solution:**
- You're not connected to master database
- Follow Method 2 or 3 above to connect directly to master
- Don't use `USE [master]` statement - connect directly

### Problem: Can't create login - permission denied
**Solution:**
- Make sure you're using an account with **server admin** role
- In Azure SQL Database, only server admin can create logins

---

## After Creating Logins

Once logins are created in master:
1. **Switch back to lms_system database**
2. **Run `grant.sql`** to create users and grant permissions

