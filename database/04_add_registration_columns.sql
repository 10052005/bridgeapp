-- ============================================================
-- BridgeApp — Phase 3, Step 1 : SCHEMA PATCH
-- Run in the "bridgeapp" database, as a whole file.
--
-- The registration form collects things the original ER diagram had
-- no column for. This adds them.
--
-- Safe to run more than once (IF NOT EXISTS on every change).
-- Does NOT delete anything — your existing data stays.
-- ============================================================

BEGIN;

-- Customer: full street address (profiles.location stays as the city).
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS address TEXT;

-- Customer: free text describing what they're looking for.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS preferred_services TEXT;

-- Seller: trading name, shown on listings instead of the owner's name.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS business_name VARCHAR(150);

-- Seller: the category they picked at signup.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS primary_category_id BIGINT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_primary_category'
    ) THEN
        ALTER TABLE profiles
            ADD CONSTRAINT fk_profiles_primary_category
            FOREIGN KEY (primary_category_id)
            REFERENCES categories (category_id) ON DELETE SET NULL;
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS ix_profiles_primary_category
    ON profiles (primary_category_id);

COMMENT ON COLUMN profiles.business_name IS
    'Seller trading name. NULL for customer accounts.';
COMMENT ON COLUMN profiles.preferred_services IS
    'Customer free text about what they need. NULL for seller accounts.';

-- The backend role needs rights on anything added later too.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO bridgeapp_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bridgeapp_app;

COMMIT;

-- Check it worked:
--   SELECT column_name FROM information_schema.columns
--   WHERE table_name = 'profiles' ORDER BY ordinal_position;
--
-- Business Description from the signup form maps to the existing
-- profiles.bio column. Portfolio upload is not stored in this phase.
