-- ============================================================
-- BridgeApp — Phase 1, Step 4 : VERIFY
-- Run in the "bridgeapp" database after seeding.
-- Every query below should return rows. Nothing here changes data.
-- ============================================================

-- 1. Row count per table -------------------------------------
SELECT 'users' AS table_name, COUNT(*) FROM users
UNION ALL SELECT 'profiles',      COUNT(*) FROM profiles
UNION ALL SELECT 'skills',        COUNT(*) FROM skills
UNION ALL SELECT 'categories',    COUNT(*) FROM categories
UNION ALL SELECT 'services',      COUNT(*) FROM services
UNION ALL SELECT 'orders',        COUNT(*) FROM orders
UNION ALL SELECT 'messages',      COUNT(*) FROM messages
UNION ALL SELECT 'admin',         COUNT(*) FROM admin
UNION ALL SELECT 'admin_actions', COUNT(*) FROM admin_actions
UNION ALL SELECT 'reports',       COUNT(*) FROM reports
UNION ALL SELECT 'logs',          COUNT(*) FROM logs
ORDER BY table_name;

-- 2. The seller listing query the home page will use ---------
SELECT s.title,
       u.name          AS seller,
       p.location,
       p.rating_avg,
       c.name          AS category,
       parent.name     AS parent_category
FROM services s
JOIN users u        ON u.user_id = s.seller_id
JOIN profiles p     ON p.user_id = u.user_id
LEFT JOIN categories c      ON c.category_id = s.category_id
LEFT JOIN categories parent ON parent.category_id = c.parent_category_id
WHERE s.status = 'active'
ORDER BY p.rating_avg DESC;

-- 3. The login query the auth route will use -----------------
SELECT user_id, name, email, role, verified, password_hash
FROM users
WHERE LOWER(email) = LOWER('ayesha@bridgeapp.demo');

-- 4. Orders with both sides of the relationship resolved -----
SELECT o.order_id,
       cust.name   AS customer,
       sell.name   AS seller,
       s.title     AS service,
       o.status,
       o.order_date::date,
       o.completion_date::date
FROM orders o
JOIN users cust  ON cust.user_id = o.customer_id
JOIN users sell  ON sell.user_id = o.seller_id
JOIN services s  ON s.service_id = o.service_id
ORDER BY o.order_date DESC;

-- 5. Unread inbox count per user -----------------------------
SELECT u.name, COUNT(*) AS unread
FROM messages m
JOIN users u ON u.user_id = m.receiver_id
WHERE m.read_status = FALSE
GROUP BY u.name;

-- 6. Category tree -------------------------------------------
SELECT COALESCE(parent.name, '(top level)') AS parent,
       c.name                               AS category
FROM categories c
LEFT JOIN categories parent ON parent.category_id = c.parent_category_id
ORDER BY parent, c.name;

-- 7. Text the recommender will vectorise later ---------------
SELECT s.service_id,
       s.title || ' ' || s.description || ' ' ||
       COALESCE(string_agg(sk.skill_description, ' '), '') AS corpus_text
FROM services s
JOIN users u    ON u.user_id = s.seller_id
JOIN profiles p ON p.user_id = u.user_id
LEFT JOIN skills sk ON sk.profile_id = p.profile_id
GROUP BY s.service_id, s.title, s.description
ORDER BY s.service_id;
