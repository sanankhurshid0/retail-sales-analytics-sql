-- ============================================================
-- RETAIL SALES ANALYTICS — Seed Data
-- File: 02_seed_data.sql
-- Description: Populates all tables with realistic sample data
-- ============================================================

-- ============================================================
-- STORES
-- ============================================================
INSERT INTO stores (store_name, city, state, region, opened_date, store_size) VALUES
('Manhattan Flagship',   'New York',      'NY', 'East',  '2015-03-15', 'Large'),
('Brooklyn Hub',         'Brooklyn',      'NY', 'East',  '2017-06-20', 'Medium'),
('LA Sunset',            'Los Angeles',   'CA', 'West',  '2016-01-10', 'Large'),
('SF Market Street',     'San Francisco', 'CA', 'West',  '2018-09-01', 'Medium'),
('Chicago Loop',         'Chicago',       'IL', 'North', '2016-11-15', 'Large'),
('Houston Galleria',     'Houston',       'TX', 'South', '2019-04-22', 'Medium'),
('Miami Beach',          'Miami',         'FL', 'South', '2020-01-07', 'Small'),
('Seattle Downtown',     'Seattle',       'WA', 'West',  '2019-07-14', 'Medium'),
('Boston Back Bay',      'Boston',        'MA', 'East',  '2017-03-30', 'Small'),
('Denver Cherry Creek',  'Denver',        'CO', 'West',  '2021-05-18', 'Small');

-- ============================================================
-- CATEGORIES (with sub-categories using parent_id)
-- ============================================================
INSERT INTO categories (category_name, parent_id) VALUES
('Electronics',    NULL),   -- 1
('Clothing',       NULL),   -- 2
('Home & Kitchen', NULL),   -- 3
('Sports',         NULL),   -- 4
('Beauty',         NULL),   -- 5
('Laptops',        1),      -- 6  (child of Electronics)
('Smartphones',    1),      -- 7
('Headphones',     1),      -- 8
('Mens Apparel',   2),      -- 9  (child of Clothing)
('Womens Apparel', 2),      -- 10
('Kitchen Tools',  3),      -- 11
('Bedding',        3),      -- 12
('Fitness',        4),      -- 13
('Outdoor',        4),      -- 14
('Skincare',       5);      -- 15

-- ============================================================
-- PRODUCTS
-- ============================================================
INSERT INTO products (product_name, category_id, brand, cost_price, list_price, launch_date) VALUES
('ProBook 15 Laptop',         6,  'TechMate',    520.00,  999.99,  '2022-01-15'),
('UltraSlim 13 Laptop',       6,  'TechMate',    680.00, 1299.99,  '2022-06-01'),
('Galaxy X12 Smartphone',     7,  'StellarTech',  350.00,  749.99,  '2022-03-20'),
('NovaPro 5 Smartphone',      7,  'NovaTech',    280.00,  599.99,  '2023-01-10'),
('BassMax Headphones',        8,  'SoundBeat',    45.00,   89.99,  '2021-09-01'),
('ProSound ANC Headphones',   8,  'SoundBeat',    95.00,  199.99,  '2022-11-15'),
('Classic Fit Chinos',        9,  'UrbanFit',     18.00,   49.99,  '2021-01-01'),
('Performance Running Shorts',9,  'UrbanFit',     12.00,   34.99,  '2021-05-15'),
('Summer Floral Dress',       10, 'BloomStyle',   22.00,   64.99,  '2022-04-01'),
('Yoga Leggings Pro',         10, 'FitFlow',      25.00,   59.99,  '2022-02-14'),
('Chef''s Knife Set',         11, 'KitchenPro',   35.00,   79.99,  '2020-06-01'),
('Non-Stick Cookware Set',    11, 'KitchenPro',   60.00,  129.99,  '2021-08-15'),
('Memory Foam Pillow',        12, 'DreamRest',    20.00,   44.99,  '2021-10-01'),
('Weighted Blanket',          12, 'DreamRest',    45.00,   89.99,  '2022-01-20'),
('Smart Fitness Watch',       13, 'PulseFit',    120.00,  249.99,  '2022-07-04'),
('Resistance Bands Set',      13, 'PulseFit',      8.00,   24.99,  '2020-03-15'),
('Hiking Backpack 40L',       14, 'TrailBlaze',   55.00,  119.99,  '2021-06-01'),
('Camping Tent 2-Person',     14, 'TrailBlaze',   80.00,  179.99,  '2021-06-01'),
('Vitamin C Serum',           15, 'GlowLab',      12.00,   34.99,  '2022-05-01'),
('Hydrating Face Cream',      15, 'GlowLab',      15.00,   44.99,  '2022-05-01');

-- ============================================================
-- CUSTOMERS  (50 customers)
-- ============================================================
INSERT INTO customers (first_name, last_name, email, gender, birth_date, city, state, signup_date, loyalty_tier) VALUES
('Alice',   'Johnson',    'alice.johnson@email.com',    'F', '1990-05-12', 'New York',     'NY', '2020-01-15', 'Gold'),
('Bob',     'Smith',      'bob.smith@email.com',        'M', '1985-08-22', 'Los Angeles',  'CA', '2020-03-10', 'Silver'),
('Carol',   'Williams',   'carol.w@email.com',          'F', '1992-11-03', 'Chicago',      'IL', '2020-06-01', 'Platinum'),
('David',   'Brown',      'david.b@email.com',          'M', '1988-02-18', 'Houston',      'TX', '2021-01-05', 'Bronze'),
('Emma',    'Jones',      'emma.jones@email.com',       'F', '1995-07-29', 'Miami',        'FL', '2021-02-20', 'Silver'),
('Frank',   'Garcia',     'frank.g@email.com',          'M', '1983-09-14', 'Seattle',      'WA', '2020-11-11', 'Gold'),
('Grace',   'Martinez',   'grace.m@email.com',          'F', '1997-01-07', 'Boston',       'MA', '2021-04-16', 'Bronze'),
('Henry',   'Davis',      'henry.d@email.com',          'M', '1979-12-25', 'Denver',       'CO', '2020-09-09', 'Platinum'),
('Iris',    'Wilson',     'iris.w@email.com',           'F', '1993-06-30', 'New York',     'NY', '2021-07-22', 'Silver'),
('James',   'Anderson',   'james.a@email.com',          'M', '1987-04-11', 'San Francisco','CA', '2020-05-05', 'Gold'),
('Karen',   'Thomas',     'karen.t@email.com',          'F', '1991-10-20', 'Los Angeles',  'CA', '2021-09-14', 'Bronze'),
('Liam',    'Jackson',    'liam.j@email.com',           'M', '1996-03-08', 'Chicago',      'IL', '2021-11-30', 'Silver'),
('Mia',     'White',      'mia.white@email.com',        'F', '1989-08-15', 'Houston',      'TX', '2022-01-18', 'Bronze'),
('Noah',    'Harris',     'noah.h@email.com',           'M', '1994-05-27', 'Miami',        'FL', '2022-02-28', 'Silver'),
('Olivia',  'Martin',     'olivia.m@email.com',         'F', '1998-12-04', 'Seattle',      'WA', '2022-04-10', 'Bronze'),
('Paul',    'Thompson',   'paul.t@email.com',           'M', '1981-07-19', 'Boston',       'MA', '2020-07-07', 'Gold'),
('Quinn',   'Garcia',     'quinn.g@email.com',          'F', '1993-02-22', 'Denver',       'CO', '2021-05-03', 'Silver'),
('Ryan',    'Martinez',   'ryan.m@email.com',           'M', '1986-11-01', 'New York',     'NY', '2020-08-25', 'Platinum'),
('Sara',    'Robinson',   'sara.r@email.com',           'F', '1999-04-13', 'Los Angeles',  'CA', '2022-06-17', 'Bronze'),
('Tom',     'Clark',      'tom.c@email.com',            'M', '1977-09-28', 'San Francisco','CA', '2019-12-01', 'Platinum'),
('Uma',     'Rodriguez',  'uma.r@email.com',            'F', '1994-06-06', 'Chicago',      'IL', '2021-03-11', 'Silver'),
('Victor',  'Lewis',      'victor.l@email.com',         'M', '1990-01-31', 'Houston',      'TX', '2021-08-22', 'Gold'),
('Wendy',   'Lee',        'wendy.l@email.com',          'F', '1988-07-17', 'Miami',        'FL', '2020-10-30', 'Gold'),
('Xander',  'Walker',     'xander.w@email.com',         'M', '1982-03-05', 'Seattle',      'WA', '2020-04-14', 'Silver'),
('Yara',    'Hall',       'yara.h@email.com',           'F', '1996-10-23', 'Boston',       'MA', '2022-07-08', 'Bronze'),
('Zara',    'Allen',      'zara.a@email.com',           'F', '1991-08-09', 'Denver',       'CO', '2021-06-19', 'Silver'),
('Aaron',   'Young',      'aaron.y@email.com',          'M', '1985-04-17', 'New York',     'NY', '2020-02-28', 'Gold'),
('Bella',   'Hernandez',  'bella.h@email.com',          'F', '1997-09-30', 'Los Angeles',  'CA', '2022-03-05', 'Bronze'),
('Carlos',  'King',       'carlos.k@email.com',         'M', '1993-12-14', 'Chicago',      'IL', '2021-10-25', 'Silver'),
('Diana',   'Wright',     'diana.w@email.com',          'F', '1987-06-07', 'Houston',      'TX', '2020-12-12', 'Gold'),
('Ethan',   'Lopez',      'ethan.l@email.com',          'M', '1999-01-20', 'Miami',        'FL', '2022-08-30', 'Bronze'),
('Fiona',   'Hill',       'fiona.h@email.com',          'F', '1984-05-24', 'Seattle',      'WA', '2019-11-15', 'Platinum'),
('George',  'Scott',      'george.s@email.com',         'M', '1992-08-11', 'Boston',       'MA', '2021-01-27', 'Silver'),
('Hannah',  'Green',      'hannah.g@email.com',         'F', '1995-03-03', 'Denver',       'CO', '2021-09-08', 'Silver'),
('Ivan',    'Adams',      'ivan.a@email.com',           'M', '1980-11-16', 'New York',     'NY', '2020-06-21', 'Gold'),
('Julia',   'Baker',      'julia.b@email.com',          'F', '1998-07-29', 'Los Angeles',  'CA', '2022-05-14', 'Bronze'),
('Kevin',   'Gonzalez',   'kevin.g@email.com',          'M', '1986-02-08', 'San Francisco','CA', '2020-09-03', 'Silver'),
('Laura',   'Nelson',     'laura.n@email.com',          'F', '1993-05-18', 'Chicago',      'IL', '2021-12-07', 'Bronze'),
('Mike',    'Carter',     'mike.c@email.com',           'M', '1978-10-01', 'Houston',      'TX', '2019-08-20', 'Platinum'),
('Nina',    'Mitchell',   'nina.m@email.com',           'F', '1997-04-25', 'Miami',        'FL', '2022-01-31', 'Bronze'),
('Oscar',   'Perez',      'oscar.p@email.com',          'M', '1989-09-12', 'Seattle',      'WA', '2021-07-16', 'Silver'),
('Petra',   'Roberts',    'petra.r@email.com',          'F', '1991-06-04', 'Boston',       'MA', '2021-04-02', 'Silver'),
('Quincy',  'Turner',     'quincy.t@email.com',         'M', '1983-01-28', 'Denver',       'CO', '2020-03-19', 'Gold'),
('Rachel',  'Phillips',   'rachel.p@email.com',         'F', '1996-11-09', 'New York',     'NY', '2022-02-10', 'Bronze'),
('Steve',   'Campbell',   'steve.c@email.com',          'M', '1975-07-22', 'Los Angeles',  'CA', '2019-06-05', 'Platinum'),
('Tina',    'Parker',     'tina.p@email.com',           'F', '1990-03-16', 'Chicago',      'IL', '2020-11-25', 'Gold'),
('Ulric',   'Evans',      'ulric.e@email.com',          'M', '1987-08-07', 'Houston',      'TX', '2021-06-30', 'Silver'),
('Violet',  'Edwards',    'violet.e@email.com',         'F', '1994-12-21', 'Miami',        'FL', '2022-04-22', 'Bronze'),
('Walter',  'Collins',    'walter.c@email.com',         'M', '1982-05-10', 'Seattle',      'WA', '2020-08-17', 'Gold'),
('Xena',    'Stewart',    'xena.s@email.com',           'F', '1998-02-14', 'Boston',       'MA', '2022-09-01', 'Bronze');

-- ============================================================
-- PROMOTIONS
-- ============================================================
INSERT INTO promotions (promo_name, discount_pct, start_date, end_date, promo_type) VALUES
('Black Friday Blowout',   25.00, '2022-11-25', '2022-11-28', 'Seasonal'),
('Summer Flash Sale',      15.00, '2022-07-04', '2022-07-07', 'Flash'),
('Back to School',         10.00, '2022-08-15', '2022-09-05', 'Seasonal'),
('Holiday Mega Sale',      20.00, '2022-12-20', '2022-12-31', 'Seasonal'),
('Loyalty Rewards Q1',     12.00, '2023-01-01', '2023-03-31', 'Loyalty'),
('Spring Refresh',          8.00, '2023-03-20', '2023-04-10', 'Seasonal'),
('Flash Friday May',       18.00, '2023-05-19', '2023-05-21', 'Flash'),
('Summer Deals 2023',      15.00, '2023-07-01', '2023-07-31', 'Seasonal'),
('Bundle & Save',          22.00, '2023-06-01', '2023-06-30', 'Bundle'),
('Black Friday 2023',      30.00, '2023-11-24', '2023-11-27', 'Seasonal');

-- ============================================================
-- ORDERS + ORDER ITEMS
-- Run a DO block to generate 500 realistic orders over 2 years
-- ============================================================
DO $$
DECLARE
    v_order_id  INT;
    v_cust_id   INT;
    v_store_id  INT;
    v_promo_id  INT;
    v_channel   VARCHAR(30);
    v_date      TIMESTAMP;
    v_num_items INT;
    v_product   INT;
    v_qty       INT;
    v_price     NUMERIC(10,2);
    v_disc      NUMERIC(5,2);
    channels    VARCHAR[] := ARRAY['In-Store','Online','Mobile'];
    statuses    VARCHAR[] := ARRAY['Completed','Completed','Completed','Completed','Returned','Cancelled'];
BEGIN
    FOR i IN 1..500 LOOP
        -- Random customer, store, channel
        v_cust_id  := floor(random() * 50 + 1)::INT;
        v_store_id := floor(random() * 10 + 1)::INT;
        v_channel  := channels[floor(random() * 3 + 1)::INT];

        -- Random date spread over 2022 and 2023 (with seasonal weighting)
        v_date := '2022-01-01'::TIMESTAMP
                  + (random() * 730)::INT * INTERVAL '1 day'
                  + (random() * 86400)::INT * INTERVAL '1 second';

        -- Randomly assign a promo ~40% of the time
        IF random() < 0.40 THEN
            v_promo_id := floor(random() * 10 + 1)::INT;
            v_disc := (SELECT discount_pct FROM promotions WHERE promo_id = v_promo_id);
        ELSE
            v_promo_id := NULL;
            v_disc := 0;
        END IF;

        INSERT INTO orders (customer_id, store_id, order_date, channel, promo_id, order_status, shipping_cost)
        VALUES (
            v_cust_id, v_store_id, v_date, v_channel, v_promo_id,
            statuses[floor(random() * 6 + 1)::INT],
            CASE WHEN v_channel = 'In-Store' THEN 0 ELSE round((random() * 15 + 5)::NUMERIC, 2) END
        )
        RETURNING order_id INTO v_order_id;

        -- 1–4 items per order
        v_num_items := floor(random() * 4 + 1)::INT;
        FOR j IN 1..v_num_items LOOP
            v_product := floor(random() * 20 + 1)::INT;
            v_qty     := floor(random() * 3 + 1)::INT;
            v_price   := (SELECT list_price FROM products WHERE product_id = v_product);

            INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct)
            VALUES (v_order_id, v_product, v_qty, v_price, v_disc);
        END LOOP;
    END LOOP;
END $$;
