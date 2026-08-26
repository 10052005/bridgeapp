# BridgeApp — Backend API (Phase 3)

Express server connecting the React app to PostgreSQL.

```
React (port 5173)  →  Express (port 4000)  →  PostgreSQL (port 5432)
```

The browser never touches the database. It asks Express, Express asks Postgres.

## Setup

**1. Patch the database.** In pgAdmin, open the `bridgeapp` database Query Tool
and run `04_add_registration_columns.sql` as a whole file. It adds the columns
the registration form needs. Safe to run twice; deletes nothing.

**2. Create your `.env`.** Copy `.env.example` to `.env` in this folder. If you
kept the password from `00_create_database.sql`, no edits needed. Otherwise put
your real one in `PGPASSWORD`.

`.env` is gitignored on purpose — it holds a password.

**3. Install and run:**

```bash
cd backend
npm install
npm run dev
```

You should see:

```
BridgeApp API listening on http://localhost:4000
Connected to database "bridgeapp"
```

If the second line is a warning instead, the database isn't reachable — see
troubleshooting below.

**4. Start the frontend in a second terminal:**

```bash
cd web
npm run dev
```

Both must be running at once. Two terminal windows.

## Check it works

Open <http://localhost:4000/api/health>. You should get:

```json
{ "status": "ok", "database": "bridgeapp", "serverTime": "..." }
```

Then log in at <http://localhost:5173/login> with `ayesha@bridgeapp.demo` /
`Demo@123`. That account lives in your database, not in the frontend code.

## Endpoints

| Method | Route | Purpose |
|---|---|---|
| GET | `/api/health` | Server and database status |
| POST | `/api/auth/register` | Create a customer or seller account |
| POST | `/api/auth/login` | Authenticate |
| GET | `/api/auth/categories` | Top-level categories for the seller dropdown |

## How security is handled

- **Passwords are hashed with bcrypt** before storage. The database never sees
  a plain password, and hashes can't be reversed. Check any row: it starts `$2b$10$`.
- **Login failures are deliberately vague.** Wrong password and unknown email
  give the same message, so nobody can probe which emails are registered.
- **Every query uses parameters** (`$1`, `$2`), never string concatenation.
  This is what prevents SQL injection.
- **Validation runs on the server**, not just the browser. Browser checks are a
  convenience; anyone can bypass them and post directly to the API.
- **Registration is a transaction.** The `users` and `profiles` rows are created
  together or not at all — no half-made accounts.

Worth a paragraph each in your report.

## Troubleshooting

**"could not reach the database"** — PostgreSQL isn't running, or `.env` has the
wrong password. Open pgAdmin; if it can't connect either, start the service:
Win+R → `services.msc` → find `postgresql-x64-16` → Start.

**"Cannot reach the server. Is the backend running on port 4000?"** in the
browser — the frontend is up but Express isn't. Start it.

**`EADDRINUSE`** — port 4000 is already taken by an old server. Close that
terminal, or change `PORT` in `.env`.

**`npm install` fails on bcrypt** — it compiles native code. On Windows, install
the LTS Node from nodejs.org rather than a portable build.

## Next

Login returns a JWT token, currently stored in `sessionStorage` and not yet used
to protect anything. Phase 4: use it to guard routes so only signed-in users
reach the dashboard.
