-- ============================================================
-- BridgeApp — Phase 1, Step 1  (pgAdmin-safe version)
-- Connect to the built-in "postgres" database before running.
--
-- IMPORTANT — HOW TO RUN THIS IN pgAdmin:
-- CREATE DATABASE cannot run inside a transaction, and pgAdmin's
-- Query Tool sends the whole script as one transaction. So run the
-- two parts below SEPARATELY:
--
--   1. Select PART A with the mouse, press F5. (Runs only the selection.)
--   2. Select PART B with the mouse, press F5.
--
-- If you use SQL Shell (psql) instead, none of this applies —
-- just run the whole file at once, it sends each statement separately.
--
-- Both parts are safe to run more than once.
-- ============================================================


-- ============================================================
-- PART A — the application login role
-- Select from "DO $$" down to "$$;" then press F5.
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bridgeapp_app') THEN
        CREATE ROLE bridgeapp_app LOGIN PASSWORD 'bridge_demo_2026';
        RAISE NOTICE 'Role bridgeapp_app created.';
    ELSE
        RAISE NOTICE 'Role bridgeapp_app already exists - skipping.';
    END IF;
END
$$;

-- Expected output: "DO" in the Messages tab, plus one of the notices above.
-- Seeing "already exists" is fine — it means your first attempt got this far.


-- ============================================================
-- PART B — the database itself
-- Select ONLY the single statement below, then press F5.
-- It must be sent on its own. Do not include PART A in the selection.
-- ============================================================

CREATE DATABASE bridgeapp
    WITH OWNER = bridgeapp_app
         ENCODING = 'UTF8'
         TEMPLATE = template0;

-- Expected output: "CREATE DATABASE".
--
-- If you get: 'database "bridgeapp" already exists'
--   -> it was created on an earlier attempt. Nothing to do, move on.
--
-- If you get: 'permission denied to create database'
--   -> you are connected as a non-superuser. Reconnect as "postgres".


-- ============================================================
-- NEXT
-- 1. In pgAdmin, right-click "Databases" -> Refresh. "bridgeapp" appears.
-- 2. Right-click the "bridgeapp" database -> Query Tool.
-- 3. Run 01_schema.sql, then 02_seed.sql, then 03_verify.sql.
--    Those three are ordinary scripts — run each one whole, no splitting.
-- ============================================================
