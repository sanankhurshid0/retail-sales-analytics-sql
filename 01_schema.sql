-- ============================================================
-- RETAIL SALES ANALYTICS — Schema Setup
-- File: 01_schema.sql
-- Author: Your Name
-- Description: Creates all tables for a retail analytics system
-- ============================================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS promotions;

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

-- Stores table
CREATE TABLE stores (
    store_id      SERIAL PRIMARY KEY,
    store_name    VARCHAR(100) NOT NULL,
    city          VARCHAR(100) NOT NULL,
    state         VARCHAR(50)  NOT NULL,
    region        VARCHAR(50)  NOT NULL,   -- 'North', 'South', 'East', 'West'
    opened_date   DATE         NOT NULL,
    store_size    VARCHAR(20)  NOT NULL    -- 'Small', 'Medium', 'Large'
);

-- Product categories table
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id     INT REFERENCES categories(category_id)   -- supports sub-categories
);

-- Products table
CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(200) NOT NULL,
    category_id   INT          NOT NULL REFERENCES categories(category_id),
    brand         VARCHAR(100),
    cost_price    NUMERIC(10,2) NOT NULL,  -- what we pay the supplier
    list_price    NUMERIC(10,2) NOT NULL,  -- normal selling price
    launch_date   DATE,
    is_active     BOOLEAN      DEFAULT TRUE
);

-- Customers table
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(200) UNIQUE NOT NULL,
    gender          VARCHAR(20),
    birth_date      DATE,
    city            VARCHAR(100),
    state           VARCHAR(50),
    signup_date     DATE         NOT NULL,
    loyalty_tier    VARCHAR(20)  DEFAULT 'Bronze'  -- Bronze, Silver, Gold, Platinum
);

-- Promotions / Discounts table
CREATE TABLE promotions (
    promo_id      SERIAL PRIMARY KEY,
    promo_name    VARCHAR(200) NOT NULL,
    discount_pct  NUMERIC(5,2) NOT NULL,   -- e.g. 15.00 means 15%
    start_date    DATE         NOT NULL,
    end_date      DATE         NOT NULL,
    promo_type    VARCHAR(50)  NOT NULL    -- 'Seasonal', 'Flash', 'Loyalty', 'Bundle'
);

-- ============================================================
-- FACT TABLES
-- ============================================================

-- Orders header table
CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT          NOT NULL REFERENCES customers(customer_id),
    store_id        INT          NOT NULL REFERENCES stores(store_id),
    order_date      TIMESTAMP    NOT NULL DEFAULT NOW(),
    channel         VARCHAR(30)  NOT NULL,   -- 'In-Store', 'Online', 'Mobile'
    promo_id        INT          REFERENCES promotions(promo_id),   -- nullable
    order_status    VARCHAR(30)  NOT NULL DEFAULT 'Completed',      -- 'Completed', 'Returned', 'Cancelled'
    shipping_cost   NUMERIC(8,2) DEFAULT 0.00
);

-- Order line items table (the main fact table)
CREATE TABLE order_items (
    item_id         SERIAL PRIMARY KEY,
    order_id        INT           NOT NULL REFERENCES orders(order_id),
    product_id      INT           NOT NULL REFERENCES products(product_id),
    quantity        INT           NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL,   -- actual price charged (may differ from list_price)
    discount_pct    NUMERIC(5,2)  DEFAULT 0.00,
    line_total      NUMERIC(12,2) GENERATED ALWAYS AS
                    (quantity * unit_price * (1 - discount_pct / 100)) STORED
);

-- ============================================================
-- INDEXES (for query performance — important to mention in interview)
-- ============================================================

-- Most analytics filter by date — index order_date
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_store      ON orders(store_id);
CREATE INDEX idx_items_order       ON order_items(order_id);
CREATE INDEX idx_items_product     ON order_items(product_id);
CREATE INDEX idx_customers_email   ON customers(email);

-- Composite index: speeds up store + date range queries significantly
CREATE INDEX idx_orders_store_date ON orders(store_id, order_date);
