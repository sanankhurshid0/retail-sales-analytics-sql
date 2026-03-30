-- ============================================================
-- RETAIL SALES ANALYTICS — Reusable Views
-- File: 04_views.sql
-- Description: Creates views that act as a clean analytics layer
-- ============================================================

-- View 1: Flat order fact — joins everything into one wide table
-- Great for quick ad-hoc queries without repeating JOINs
CREATE OR REPLACE VIEW vw_order_fact AS
SELECT
    o.order_id,
    o.order_date,
    o.channel,
    o.order_status,
    o.shipping_cost,
    -- Customer
    c.customer_id,
    c.first_name || ' ' || c.last_name      AS customer_name,
    c.loyalty_tier,
    c.state                                 AS customer_state,
    -- Store
    s.store_id,
    s.store_name,
    s.city                                  AS store_city,
    s.region,
    -- Product
    p.product_id,
    p.product_name,
    cat.category_name,
    p.brand,
    -- Financials
    oi.quantity,
    oi.unit_price,
    oi.discount_pct,
    oi.line_total,
    oi.quantity * p.cost_price              AS cogs,
    oi.line_total - (oi.quantity * p.cost_price) AS gross_profit
FROM orders o
JOIN order_items oi  ON o.order_id   = oi.order_id
JOIN customers  c    ON o.customer_id = c.customer_id
JOIN stores     s    ON o.store_id    = s.store_id
JOIN products   p    ON oi.product_id = p.product_id
JOIN categories cat  ON p.category_id = cat.category_id;


-- View 2: Monthly KPI summary — one row per month for dashboards
CREATE OR REPLACE VIEW vw_monthly_kpis AS
WITH base AS (
    SELECT
        DATE_TRUNC('month', order_date)    AS month,
        order_id,
        customer_id,
        line_total,
        gross_profit
    FROM vw_order_fact
    WHERE order_status = 'Completed'
)
SELECT
    TO_CHAR(month, 'YYYY-MM')              AS month,
    COUNT(DISTINCT order_id)               AS orders,
    COUNT(DISTINCT customer_id)            AS unique_customers,
    ROUND(SUM(line_total), 2)              AS revenue,
    ROUND(SUM(gross_profit), 2)            AS gross_profit,
    ROUND(AVG(line_total), 2)              AS avg_order_value,
    ROUND(SUM(gross_profit) / NULLIF(SUM(line_total), 0) * 100, 2) AS gross_margin_pct
FROM base
GROUP BY 1
ORDER BY 1;


-- View 3: Customer RFM snapshot — used by the segmentation queries
CREATE OR REPLACE VIEW vw_customer_rfm AS
WITH base AS (
    SELECT
        customer_id,
        MAX(order_date)::DATE             AS last_purchase_date,
        COUNT(DISTINCT order_id)          AS frequency,
        ROUND(SUM(line_total), 2)         AS monetary
    FROM vw_order_fact
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT
    b.*,
    c.first_name || ' ' || c.last_name   AS customer_name,
    c.loyalty_tier,
    CURRENT_DATE - b.last_purchase_date  AS recency_days
FROM base b
JOIN customers c ON b.customer_id = c.customer_id;
