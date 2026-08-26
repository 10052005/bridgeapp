-- ============================================================
-- BridgeApp — Phase 1, Step 2 : SCHEMA
-- Run this while connected to the "bridgeapp" database.
--
-- This script is re-runnable: it drops and rebuilds every table,
-- so you can fix a mistake and just run it again from the top.
-- Running it WILL delete all existing data in these tables.
-- ============================================================

BEGIN;

DROP TABLE IF EXISTS logs           CASCADE;
DROP TABLE IF EXISTS reports        CASCADE;
DROP TABLE IF EXISTS admin_actions  CASCADE;
DROP TABLE IF EXISTS admin          CASCADE;
DROP TABLE IF EXISTS messages       CASCADE;
DROP TABLE IF EXISTS orders         CASCADE;
DROP TABLE IF EXISTS services       CASCADE;
DROP TABLE IF EXISTS categories     CASCADE;
DROP TABLE IF EXISTS skills         CASCADE;
DROP TABLE IF EXISTS profiles       CASCADE;
DROP TABLE IF EXISTS users          CASCADE;


-- ------------------------------------------------------------
-- USERS  — every human account (customer, seller, admin)
-- ------------------------------------------------------------
CREATE TABLE users (
    user_id       BIGSERIAL   PRIMARY KEY,
    name          VARCHAR(120) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    password_hash TEXT         NOT NULL,
    phone         VARCHAR(20),
    verified      BOOLEAN      NOT NULL DEFAULT FALSE,
    role          VARCHAR(10)  NOT NULL DEFAULT 'customer',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT ck_users_role  CHECK (role IN ('customer', 'seller', 'admin')),
    CONSTRAINT ck_users_email CHECK (POSITION('@' IN email) > 1)
);

-- Case-insensitive uniqueness: Ayesha@mail.com and ayesha@mail.com
-- must not be two different accounts.
CREATE UNIQUE INDEX ux_users_email_lower ON users (LOWER(email));

COMMENT ON COLUMN users.password_hash IS
    'bcrypt hash only. Never store a plain-text password.';


-- ------------------------------------------------------------
-- PROFILES — one optional public profile per user (1:1)
-- ------------------------------------------------------------
CREATE TABLE profiles (
    profile_id      BIGSERIAL PRIMARY KEY,
    user_id         BIGINT       NOT NULL,
    bio             TEXT,
    location        VARCHAR(120),
    profile_picture TEXT,
    rating_avg      NUMERIC(3,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT fk_profiles_user  FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT uq_profiles_user  UNIQUE (user_id),          -- enforces 1:1
    CONSTRAINT ck_profiles_rating CHECK (rating_avg >= 0 AND rating_avg <= 5)
);

COMMENT ON COLUMN profiles.profile_picture IS
    'Relative path or URL to the stored image, not the image bytes.';


-- ------------------------------------------------------------
-- SKILLS — many skills per profile (1:M)
-- ------------------------------------------------------------
CREATE TABLE skills (
    skill_id          BIGSERIAL PRIMARY KEY,
    profile_id        BIGINT NOT NULL,
    skill_description TEXT   NOT NULL,

    CONSTRAINT fk_skills_profile FOREIGN KEY (profile_id)
        REFERENCES profiles (profile_id) ON DELETE CASCADE
);

CREATE INDEX ix_skills_profile ON skills (profile_id);


-- ------------------------------------------------------------
-- CATEGORIES — self-referencing tree (parent / child)
-- ------------------------------------------------------------
CREATE TABLE categories (
    category_id        BIGSERIAL PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    description        TEXT,
    parent_category_id BIGINT,

    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id)
        REFERENCES categories (category_id) ON DELETE SET NULL,
    CONSTRAINT uq_categories_name   UNIQUE (name),
    CONSTRAINT ck_categories_parent CHECK (parent_category_id IS DISTINCT FROM category_id)
);

CREATE INDEX ix_categories_parent ON categories (parent_category_id);


-- ------------------------------------------------------------
-- SERVICES — what a seller offers
-- ------------------------------------------------------------
CREATE TABLE services (
    service_id  BIGSERIAL PRIMARY KEY,
    seller_id   BIGINT       NOT NULL,
    category_id BIGINT,
    title       VARCHAR(150) NOT NULL,
    description TEXT         NOT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'active',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT fk_services_seller   FOREIGN KEY (seller_id)
        REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_services_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id) ON DELETE SET NULL,
    CONSTRAINT ck_services_status   CHECK (status IN ('active', 'paused', 'removed'))
);

CREATE INDEX ix_services_seller   ON services (seller_id);
CREATE INDEX ix_services_category ON services (category_id);
CREATE INDEX ix_services_status   ON services (status);

COMMENT ON COLUMN services.description IS
    'Required and non-empty: this is the text the TF-IDF recommender scores.';


-- ------------------------------------------------------------
-- ORDERS — a customer booking a seller''s service
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id        BIGSERIAL PRIMARY KEY,
    customer_id     BIGINT      NOT NULL,
    seller_id       BIGINT      NOT NULL,
    service_id      BIGINT      NOT NULL,
    category_id     BIGINT,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending',
    order_date      TIMESTAMPTZ NOT NULL DEFAULT now(),
    completion_date TIMESTAMPTZ,

    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES users (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_seller   FOREIGN KEY (seller_id)
        REFERENCES users (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_service  FOREIGN KEY (service_id)
        REFERENCES services (service_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id) ON DELETE SET NULL,

    CONSTRAINT ck_orders_status CHECK (
        status IN ('pending', 'accepted', 'in_progress', 'completed', 'cancelled')),
    CONSTRAINT ck_orders_parties CHECK (customer_id <> seller_id),
    CONSTRAINT ck_orders_dates   CHECK (
        completion_date IS NULL OR completion_date >= order_date),
    -- A completed order must have a completion date, and vice versa.
    CONSTRAINT ck_orders_completed CHECK (
        (status = 'completed' AND completion_date IS NOT NULL)
        OR (status <> 'completed' AND completion_date IS NULL))
);

CREATE INDEX ix_orders_customer ON orders (customer_id);
CREATE INDEX ix_orders_seller   ON orders (seller_id);
CREATE INDEX ix_orders_service  ON orders (service_id);
CREATE INDEX ix_orders_status   ON orders (status);


-- ------------------------------------------------------------
-- MESSAGES — direct chat between two users
-- ------------------------------------------------------------
CREATE TABLE messages (
    message_id  BIGSERIAL PRIMARY KEY,
    sender_id   BIGINT      NOT NULL,
    receiver_id BIGINT      NOT NULL,
    content     TEXT        NOT NULL,
    "timestamp" TIMESTAMPTZ NOT NULL DEFAULT now(),
    read_status BOOLEAN     NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_messages_sender   FOREIGN KEY (sender_id)
        REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id)
        REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT ck_messages_parties  CHECK (sender_id <> receiver_id)
);

-- Fetching one conversation, newest first, is the hot query.
CREATE INDEX ix_messages_thread ON messages (sender_id, receiver_id, "timestamp" DESC);
CREATE INDEX ix_messages_inbox  ON messages (receiver_id, read_status);


-- ------------------------------------------------------------
-- ADMIN — extra details for platform administrators
-- ------------------------------------------------------------
CREATE TABLE admin (
    admin_id        BIGSERIAL PRIMARY KEY,
    full_name       VARCHAR(120) NOT NULL,
    profile_picture TEXT,
    user_id         BIGINT,

    CONSTRAINT fk_admin_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE SET NULL,
    CONSTRAINT uq_admin_user UNIQUE (user_id)
);

COMMENT ON COLUMN admin.user_id IS
    'Links the admin record to the login account in users (role = admin).';


-- ------------------------------------------------------------
-- ADMIN_ACTIONS — audit trail of moderation actions
-- ------------------------------------------------------------
CREATE TABLE admin_actions (
    action_id   BIGSERIAL PRIMARY KEY,
    admin_id    BIGINT      NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    target_id   BIGINT,
    "timestamp" TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_admin_actions_admin FOREIGN KEY (admin_id)
        REFERENCES admin (admin_id) ON DELETE CASCADE
);

CREATE INDEX ix_admin_actions_admin ON admin_actions (admin_id);

COMMENT ON COLUMN admin_actions.target_id IS
    'ID of whatever was acted on (a user, service or order). Deliberately not a
     foreign key, because the target table varies by action_type.';


-- ------------------------------------------------------------
-- REPORTS — written notes attached to an admin action
-- ------------------------------------------------------------
CREATE TABLE reports (
    report_id  BIGSERIAL PRIMARY KEY,
    admin_id   BIGINT      NOT NULL,
    action_id  BIGINT,
    content    TEXT        NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_reports_admin  FOREIGN KEY (admin_id)
        REFERENCES admin (admin_id) ON DELETE CASCADE,
    CONSTRAINT fk_reports_action FOREIGN KEY (action_id)
        REFERENCES admin_actions (action_id) ON DELETE SET NULL
);

CREATE INDEX ix_reports_admin ON reports (admin_id);


-- ------------------------------------------------------------
-- LOGS — general user activity trail
-- ------------------------------------------------------------
CREATE TABLE logs (
    log_id             BIGSERIAL PRIMARY KEY,
    user_id            BIGINT,
    activity_performed TEXT        NOT NULL,
    activity_type      VARCHAR(50) NOT NULL,
    "timestamp"        TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_logs_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE SET NULL
);

CREATE INDEX ix_logs_user ON logs (user_id, "timestamp" DESC);

COMMENT ON COLUMN logs.user_id IS
    'Nullable on purpose: the log survives if the account is deleted.';


-- ------------------------------------------------------------
-- Permissions for the backend login role
-- ------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO bridgeapp_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bridgeapp_app;

COMMIT;
