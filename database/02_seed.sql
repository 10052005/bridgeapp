-- ============================================================
-- BridgeApp — Phase 1, Step 3 : SEED DATA
-- Run while connected to the "bridgeapp" database, after 01_schema.sql.
--
-- Every demo account uses the password:  Demo@123
-- The stored hash is a real bcrypt hash of that password, so your
-- Node login route will verify it correctly with bcrypt.compare().
-- ============================================================

BEGIN;

-- ---------- USERS -------------------------------------------
INSERT INTO users (name, email, password_hash, phone, verified, role) VALUES
('Ayesha Siddiqui',  'ayesha@bridgeapp.demo',  '$2b$10$mVDgZ2dnuARfjogNGnTMcudc0Jt4FEF6Hv53COMXj4nAU/MdlfJ76', '+923001234567', TRUE,  'seller'),
('Fatima Noor',      'fatima@bridgeapp.demo',  '$2b$10$mVDgZ2dnuARfjogNGnTMcudc0Jt4FEF6Hv53COMXj4nAU/MdlfJ76', '+923112345678', TRUE,  'seller'),
('Sana Khan',        'sana@bridgeapp.demo',    '$2b$10$mVDgZ2dnuARfjogNGnTMcudc0Jt4FEF6Hv53COMXj4nAU/MdlfJ76', '+923223456789', FALSE, 'seller'),
('Bilal Ahmed',      'bilal@bridgeapp.demo',   '$2b$10$mVDgZ2dnuARfjogNGnTMcudc0Jt4FEF6Hv53COMXj4nAU/MdlfJ76', '+923334567890', TRUE,  'customer'),
('Hina Raza',        'hina@bridgeapp.demo',    '$2b$10$mVDgZ2dnuARfjogNGnTMcudc0Jt4FEF6Hv53COMXj4nAU/MdlfJ76', '+923445678901', TRUE,  'customer'),
('Platform Admin',   'admin@bridgeapp.demo',   '$2b$10$mVDgZ2dnuARfjogNGnTMcudc0Jt4FEF6Hv53COMXj4nAU/MdlfJ76', '+923556789012', TRUE,  'admin');

-- ---------- PROFILES ----------------------------------------
-- Sub-queries look the user up by email, so this stays correct
-- even if the generated IDs shift.
INSERT INTO profiles (user_id, bio, location, profile_picture, rating_avg)
SELECT user_id, v.bio, v.location, v.pic, v.rating
FROM users u
JOIN (VALUES
    ('ayesha@bridgeapp.demo', 'Home-based tailor with 8 years of experience in bridal and formal stitching.', 'Gulshan-e-Iqbal, Karachi', '/uploads/profiles/ayesha.jpg', 4.70),
    ('fatima@bridgeapp.demo', 'Certified beautician offering bridal makeup, mehndi and skincare at home.',   'North Nazimabad, Karachi', '/uploads/profiles/fatima.jpg', 4.40),
    ('sana@bridgeapp.demo',   'Mathematics and physics tutor for O-level and matric students.',              'DHA Phase 5, Karachi',     '/uploads/profiles/sana.jpg',   4.90),
    ('bilal@bridgeapp.demo',  'Looking for reliable home services around Karachi.',                          'Clifton, Karachi',         NULL,                            0.00),
    ('hina@bridgeapp.demo',   'Working mother, mostly books tutoring and tailoring.',                        'Bahadurabad, Karachi',     NULL,                            0.00)
) AS v(email, bio, location, pic, rating) ON LOWER(u.email) = v.email;

-- ---------- SKILLS ------------------------------------------
INSERT INTO skills (profile_id, skill_description)
SELECT p.profile_id, v.skill
FROM profiles p
JOIN users u ON u.user_id = p.user_id
JOIN (VALUES
    ('ayesha@bridgeapp.demo', 'Bridal dress stitching'),
    ('ayesha@bridgeapp.demo', 'Hand embroidery and zari work'),
    ('ayesha@bridgeapp.demo', 'Alterations and size fitting'),
    ('fatima@bridgeapp.demo', 'Bridal and party makeup'),
    ('fatima@bridgeapp.demo', 'Mehndi and henna design'),
    ('sana@bridgeapp.demo',   'O-level mathematics'),
    ('sana@bridgeapp.demo',   'Physics and general science'),
    ('sana@bridgeapp.demo',   'Exam preparation and past papers')
) AS v(email, skill) ON LOWER(u.email) = v.email;

-- ---------- CATEGORIES --------------------------------------
-- Parents first, then children that point back at them.
INSERT INTO categories (name, description) VALUES
('Tailoring & Stitching', 'Clothing made, altered or repaired to order.'),
('Beauty & Wellness',     'Personal grooming and beauty services.'),
('Education & Tutoring',  'Academic tutoring and skills teaching.'),
('Food & Catering',       'Home-cooked food, tiffin and event catering.'),
('Handicrafts',           'Handmade decorative and gift items.');

INSERT INTO categories (name, description, parent_category_id)
SELECT v.name, v.descr, c.category_id
FROM categories c
JOIN (VALUES
    ('Bridal Stitching',   'Wedding and formal wear stitching.',            'Tailoring & Stitching'),
    ('Kids Clothing',      'Stitching for children of all ages.',           'Tailoring & Stitching'),
    ('Bridal Makeup',      'Full bridal makeup and styling.',               'Beauty & Wellness'),
    ('Mehndi Art',         'Henna application for events and weddings.',    'Beauty & Wellness'),
    ('School Tutoring',    'Matric, O-level and A-level subject tutoring.', 'Education & Tutoring'),
    ('Quran Teaching',     'Quran recitation and tajweed lessons.',         'Education & Tutoring')
) AS v(name, descr, parent) ON c.name = v.parent;

-- ---------- SERVICES ----------------------------------------
INSERT INTO services (seller_id, category_id, title, description, status)
SELECT u.user_id, c.category_id, v.title, v.descr, v.status
FROM (VALUES
    ('ayesha@bridgeapp.demo', 'Bridal Stitching', 'Custom bridal lehenga stitching',
     'Complete bridal lehenga and maxi stitching with hand embroidery, zari work and dori detailing. Includes two fitting sessions at home and delivery within three weeks.', 'active'),
    ('ayesha@bridgeapp.demo', 'Kids Clothing', 'Kids party frocks and kurta sets',
     'Stitching of frocks, kurta pajama and school uniforms for children aged two to twelve. Soft cotton and lawn fabrics, quick three day turnaround.', 'active'),
    ('fatima@bridgeapp.demo', 'Bridal Makeup', 'Bridal makeup package at your home',
     'Full bridal makeup including base, contouring, hair styling, dupatta setting and saree draping. HD products used, trial session available before the wedding day.', 'active'),
    ('fatima@bridgeapp.demo', 'Mehndi Art', 'Traditional and Arabic mehndi design',
     'Intricate bridal mehndi covering hands, arms and feet in traditional Pakistani or Arabic style. Organic henna cone prepared fresh for deep colour.', 'active'),
    ('sana@bridgeapp.demo',   'School Tutoring', 'O-level mathematics home tuition',
     'Weekly mathematics tuition for O-level and matric students covering algebra, trigonometry, geometry and past paper practice with monthly progress reports.', 'active'),
    ('sana@bridgeapp.demo',   'School Tutoring', 'Physics crash course before exams',
     'Intensive four week physics revision course focused on numericals, definitions and exam technique for board and O-level candidates.', 'paused')
) AS v(email, cat, title, descr, status)
JOIN users u      ON LOWER(u.email) = v.email
JOIN categories c ON c.name = v.cat;

-- ---------- ORDERS ------------------------------------------
INSERT INTO orders (customer_id, seller_id, service_id, category_id, status, order_date, completion_date)
SELECT cu.user_id, s.seller_id, s.service_id, s.category_id, v.status,
       now() - v.days_ago * INTERVAL '1 day',
       CASE WHEN v.status = 'completed'
            THEN now() - (v.days_ago - 5) * INTERVAL '1 day'
            ELSE NULL END
FROM (VALUES
    ('bilal@bridgeapp.demo', 'Custom bridal lehenga stitching',   'completed',   30),
    ('hina@bridgeapp.demo',  'O-level mathematics home tuition',  'in_progress', 12),
    ('hina@bridgeapp.demo',  'Kids party frocks and kurta sets',  'pending',      2),
    ('bilal@bridgeapp.demo', 'Bridal makeup package at your home','accepted',     6),
    ('bilal@bridgeapp.demo', 'Traditional and Arabic mehndi design','cancelled', 20)
) AS v(cust_email, service_title, status, days_ago)
JOIN users cu   ON LOWER(cu.email) = v.cust_email
JOIN services s ON s.title = v.service_title;

-- ---------- MESSAGES ----------------------------------------
INSERT INTO messages (sender_id, receiver_id, content, "timestamp", read_status)
SELECT snd.user_id, rcv.user_id, v.content, now() - v.mins_ago * INTERVAL '1 minute', v.is_read
FROM (VALUES
    ('bilal@bridgeapp.demo', 'ayesha@bridgeapp.demo', 'Assalam o alaikum, do you take bridal orders for next month?', 4320, TRUE),
    ('ayesha@bridgeapp.demo','bilal@bridgeapp.demo',  'Walaikum assalam, yes I have slots open. Please share the design.', 4300, TRUE),
    ('bilal@bridgeapp.demo', 'ayesha@bridgeapp.demo', 'Sending the picture now. What would the total cost be?', 4280, TRUE),
    ('hina@bridgeapp.demo',  'sana@bridgeapp.demo',   'Can we shift Tuesday class to 6 pm this week?', 180, TRUE),
    ('sana@bridgeapp.demo',  'hina@bridgeapp.demo',   'Yes that works. See you at 6.', 150, FALSE),
    ('hina@bridgeapp.demo',  'ayesha@bridgeapp.demo', 'Do you stitch school uniforms as well?', 40, FALSE)
) AS v(sender, receiver, content, mins_ago, is_read)
JOIN users snd ON LOWER(snd.email) = v.sender
JOIN users rcv ON LOWER(rcv.email) = v.receiver;

-- ---------- ADMIN -------------------------------------------
INSERT INTO admin (full_name, profile_picture, user_id)
SELECT 'Platform Admin', '/uploads/profiles/admin.png', user_id
FROM users WHERE LOWER(email) = 'admin@bridgeapp.demo';

-- ---------- ADMIN ACTIONS -----------------------------------
INSERT INTO admin_actions (admin_id, action_type, target_id, "timestamp")
SELECT a.admin_id, v.action_type, v.target_id, now() - v.days_ago * INTERVAL '1 day'
FROM admin a
JOIN (VALUES
    ('verify_user',    (SELECT user_id FROM users WHERE LOWER(email) = 'ayesha@bridgeapp.demo'), 45),
    ('verify_user',    (SELECT user_id FROM users WHERE LOWER(email) = 'fatima@bridgeapp.demo'), 40),
    ('pause_service',  (SELECT service_id FROM services WHERE title = 'Physics crash course before exams'), 8)
) AS v(action_type, target_id, days_ago) ON TRUE;

-- ---------- REPORTS -----------------------------------------
INSERT INTO reports (admin_id, action_id, content)
SELECT aa.admin_id, aa.action_id,
       'CNIC and address confirmed during onboarding call. Seller marked as verified.'
FROM admin_actions aa
WHERE aa.action_type = 'verify_user'
LIMIT 1;

INSERT INTO reports (admin_id, action_id, content)
SELECT aa.admin_id, aa.action_id,
       'Listing paused at the seller''s own request until exam season ends.'
FROM admin_actions aa
WHERE aa.action_type = 'pause_service';

-- ---------- LOGS --------------------------------------------
INSERT INTO logs (user_id, activity_performed, activity_type, "timestamp")
SELECT u.user_id, v.performed, v.atype, now() - v.mins_ago * INTERVAL '1 minute'
FROM (VALUES
    ('bilal@bridgeapp.demo',  'Signed in from the web application',      'auth',    5000),
    ('bilal@bridgeapp.demo',  'Placed an order for bridal stitching',    'order',   4900),
    ('ayesha@bridgeapp.demo', 'Created a new service listing',           'service', 4700),
    ('hina@bridgeapp.demo',   'Registered a new customer account',       'auth',     600),
    ('sana@bridgeapp.demo',   'Updated profile bio and location',        'profile',  300)
) AS v(email, performed, atype, mins_ago)
JOIN users u ON LOWER(u.email) = v.email;

COMMIT;
