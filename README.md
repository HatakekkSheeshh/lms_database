# LMS System Database Setup Guide

This repository hosts everything needed to provision the LMS (Learning Management System) database: base schema, seed data, stored procedures, views, triggers, utilities, and test fixtures.

## Prerequisites

- SQL Server 2019 (or later) with permissions to create/drop databases
- SQL Server Management Studio (SSMS) or Azure Data Studio
- `Vietnamese_100_CI_AS` collation installed on the SQL Server instance

## Setup Workflow

### 1. Create the database

Run `create_database.sql` to create (or recreate) the `lms_system` database with the correct collation. The script safely drops the existing database before recreating it.

### 2. Create the schema

Run `database/lms_database.sql` to build all core tables: `Users`, `Account`, `Student`, `Tutor`, `Course`, `Section`, `Assessment`, `Assignment`, `Quiz`, `Submission`, and supporting tables. The script uses `NVARCHAR` columns and applies the Vietnamese collation everywhere text is stored.

### 3. Seed essential data

Start with `insert/insert_users.sql`, which loads 464 users extracted from `data_mock/user_db.json`. All Unicode literals already use the `N` prefix (for example `N'Nguyễn'`). Additional inserts are organized in the same folder if you need to populate other tables.

### 4. Verify the deployment

```sql
USE [lms_system];
GO

SELECT COUNT(*) AS TotalUsers FROM [Users];

SELECT TOP 10 University_ID, First_Name, Last_Name
FROM [Users]
ORDER BY University_ID;

SELECT name, collation_name
FROM sys.databases
WHERE name = 'lms_system';
```

## Quick start (run-all)

1. `create_database.sql`
2. `database/lms_database.sql`
3. `insert/insert_users.sql`
4. Any verification query you need, e.g. `SELECT COUNT(*) FROM [Users];`

## Folder notes

- `amend/` — one-off corrective scripts created while debugging production data (kept separate so patches can be replayed without touching the main schema).
- `blob_storage/` — sample scripts that load large data objects; isolated to mimic Azure Blob ingestion routines.
- `data_mock/` — JSON, CSV, and PDF artifacts that back every insert script; separating raw data keeps SQL scripts lightweight.
- `database/` — authoritative DDL; only this folder should define the base schema so upgrades stay traceable.
- `example/` — runnable demos and manual tests showing how to call procedures/triggers; keeps README concise while still preserving usage references.
- `fix_table/` — structural hot-fixes (add/drop columns, cascade rules) that must be applied sequentially during schema evolution; stored apart from the clean DDL.
- `foreignkey_seek/` — investigative scripts that trace FK relationships when diagnosing constraint failures.
- `function/` — scalar/table-valued functions extracted from procedures to encourage reuse.
- `insert/` — deterministic seed data grouped per entity; splitting by entity makes it easy to reseed a single table.
- `mock/` — end-to-end login and assessment simulations, helpful for QA without polluting production data.
- `procedures/` — CRUD, reporting, and orchestration procedures; isolating them here avoids noise in the core schema folder.
- `security/` — role/grant definitions so permission changes are versioned independently.
- `trigger/` — DML triggers (validation, auditing, automation) grouped to simplify enable/disable flows during maintenance.
- `view/` — reporting/projection views; segregated so analytics teams can extend them without editing procedures.

Standalone root file:

- `create_database.sql` — bootstrap database with correct collation.

## Database schema overview

Main logical areas:

- **Identity & Access** — `Users`, `Account`, `Admin`, `Student`, `Tutor`.
- **Course Delivery** — `Course`, `Section`, `Scheduler`, `TakesPlace`.
- **Assessment Pipeline** — `Assessment`, `Assignment`, `Quiz`, `Submission`, feedback tables.
- **Reference Data** — campus buildings, rooms, equipment, and platform metadata.

## Troubleshooting

- **Vietnamese characters show as `?`** — truncate affected rows and rerun the relevant `insert/*.sql` script (they all enforce the `N` prefix and NVARCHAR columns).
- **Foreign key constraint failures** — ensure `database/lms_database.sql` completes before running any insert or fix script, and execute `fix_table/` patches in order.
- **Database already exists** — re-run `create_database.sql`; it drops and recreates the database in one go.

## Operational notes

- Unicode everywhere: all textual columns use `NVARCHAR` and `Vietnamese_100_CI_AS`.
- Sample data volume: 464 verified user records (extendible via `data_mock/`).
- Keep procedure/function/view changes within their folders so git history remains readable.

## Support checklist

1. SQL Server version ≥ 2019.
2. Database collation matches `Vietnamese_100_CI_AS`.
3. All INSERT statements use the `N` prefix for Unicode literals.
4. Run scripts in the order described above before reporting an issue.
