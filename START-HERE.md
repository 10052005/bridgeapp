# BridgeApp — how to run it

Three folders:

- `database/` — SQL scripts (PostgreSQL)
- `backend/`  — Express API
- `web/`      — React frontend

## First time

1. **Database**: in pgAdmin, on the `bridgeapp` database, run
   `database/04_add_registration_columns.sql`.
   (If you haven't built the database yet, run 00 → 01 → 02 first.)

2. **Backend**: copy `backend/.env.example` to `backend/.env`, then:
   ```
   cd backend
   npm install
   npm run dev
   ```
   Wait for: `Connected to database "bridgeapp"`

3. **Frontend**, in a SECOND terminal window:
   ```
   cd web
   npm install
   npm run dev
   ```

4. Open http://localhost:5173

## Every time after

Two terminals: `npm run dev` in `backend`, `npm run dev` in `web`.
Both must be running. Closing a terminal stops that half.

## Test login

`ayesha@bridgeapp.demo` / `Demo@123` — this account is in your database.

Register a new account, then log in with it. It will still be there after a
restart, because it is now saved in PostgreSQL rather than in memory.
