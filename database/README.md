# BridgeApp — Database (Phase 1)

PostgreSQL schema for the BridgeApp demo. Keep this folder in your repo as `/database`.

## Run order

| Step | File | Connect to | Purpose |
|---|---|---|---|
| 1 | `00_create_database.sql` | `postgres` database | Creates the `bridgeapp` database and the `bridgeapp_app` login role. **In pgAdmin, run its two parts separately** — see the notes inside the file. |
| 2 | `01_schema.sql` | `bridgeapp` database | Creates all 11 tables, constraints and indexes |
| 3 | `02_seed.sql` | `bridgeapp` database | Inserts demo data |
| 4 | `03_verify.sql` | `bridgeapp` database | Read-only checks — proves everything wired up correctly |

`01_schema.sql` and `02_seed.sql` are safe to re-run. The schema script drops and
rebuilds every table, so re-running both together gives you a clean database.

## Demo accounts

All accounts use the password **`Demo@123`** (stored as a real bcrypt hash, so
`bcrypt.compare()` in your Node backend will verify it).

| Email | Role |
|---|---|
| `ayesha@bridgeapp.demo` | seller |
| `fatima@bridgeapp.demo` | seller |
| `sana@bridgeapp.demo` | seller (unverified) |
| `bilal@bridgeapp.demo` | customer |
| `hina@bridgeapp.demo` | customer |
| `admin@bridgeapp.demo` | admin |

## Backend connection string

Put this in `backend/.env` (and add `.env` to `.gitignore`):

```
DATABASE_URL=postgresql://bridgeapp_app:bridge_demo_2026@localhost:5432/bridgeapp
```

## Changes made to the ER diagram

These were required to make the diagram valid, runnable SQL. Note them in your
report — examiners generally credit a documented correction over a silent one.

1. **`logs` had no primary key.** Added `log_id`.
2. **`users.password` renamed to `password_hash`.** Storing a plain password
   would be flagged in any security section of your report.
3. **`orders.completion_data` renamed to `completion_date`** (typo in diagram).
4. **`logs.activity_perfformed` renamed to `activity_performed`** (typo).
5. **`admin.user_id` added.** The diagram's `Admin` table has no email or
   password, so an admin could never log in. This column links the admin record
   to its login account in `users` where `role = 'admin'`.
6. **`created_at` added** to `users`, `services` and `reports` — needed for
   "newest first" sorting on the home page.
7. **`orders.category_id` kept as-is**, even though it can be derived from
   `services`. It is in your approved diagram, and it makes category filtering
   on order history a single-table read. Just make sure your backend copies the
   value from the service when creating an order.

Everything else matches the diagram exactly, including table and column names.
