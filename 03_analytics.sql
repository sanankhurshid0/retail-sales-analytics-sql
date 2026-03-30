-- ============================================================
-- RETAIL SALES ANALYTICS — Advanced Analytics Queries
-- File: 03_analytics.sql
-- Description: 20+ analytics queries covering all key areas
-- ============================================================


-- ============================================================
-- SECTION 1: REVENUE TRENDS
-- ============================================================

-- 1.1 Monthly revenue trend with growth rate (MoM%)
-- Technique: Window function LAG() to compare with previous month
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date)    AS month,
        SUM(oi.line_total)                   AS revenue,
        COUNT(DISTINCT o.order_id)           AS orders,
        COUNT(DISTINCT o.customer_id)        AS unique_customers
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY 1
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                                          AS month,
    ROUND(revenue, 2)                                                  AS revenue,
    orders,
    unique_customers,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 2
    )                                                                  AS mom_growth_pct,
    ROUND(SUM(revenue) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING), 2) AS cumulative_revenue
FROM monthly_revenue
ORDER BY month;


-- 1.2 Year-over-year comparison by quarter
SELECT
    EXTRACT(YEAR  FROM o.order_date)          AS year,
    EXTRACT(QUARTER FROM o.order_date)        AS quarter,
    ROUND(SUM(oi.line_total), 2)              AS revenue,
    COUNT(DISTINCT o.order_id)                AS total_orders,
    ROUND(AVG(oi.line_total), 2)              AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2
ORDER BY 1, 2;


-- 1.3 Rolling 3-month average revenue (smoothed trend)
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.line_total)                AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY 1
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                                           AS month,
    ROUND(revenue, 2)                                                   AS monthly_revenue,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS 2 PRECEDING), 2)      AS rolling_3m_avg
FROM monthly
ORDER BY month;


-- ============================================================
-- SECTION 2: CUSTOMER BEHAVIOUR — RFM ANALYSIS
-- ============================================================
-- RFM = Recency (days since last purchase)
--       Frequency (number of orders)
--       Monetary (total spend)
-- A classic customer segmentation technique

-- 2.1 Build RFM scores for every customer
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name                      AS customer_name,
        c.loyalty_tier,
        MAX(o.order_date)::DATE                                  AS last_purchase_date,
        COUNT(DISTINCT o.order_id)                               AS frequency,
        ROUND(SUM(oi.line_total), 2)                             AS monetary
    FROM customers c
    JOIN orders o  ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY 1, 2, 3
),
rfm_with_recency AS (
    SELECT *,
        CURRENT_DATE - last_purchase_date AS recency_days
    FROM rfm_base
),
rfm_scored AS (
    SELECT *,
        -- Score 1–5 using NTILE (5 = best)
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,   -- lower days = higher score
        NTILE(5) OVER (ORDER BY frequency     ASC)  AS f_score,
        NTILE(5) OVER (ORDER BY monetary      ASC)  AS m_score
    FROM rfm_with_recency
)
SELECT
    customer_id,
    customer_name,
    loyalty_tier,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score                         AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4              THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3              THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2              THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3              THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2              THEN 'Lost'
        ELSE                                                 'Potential Loyalist'
    END                                                 AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total DESC;


-- 2.2 RFM segment summary (how many customers in each bucket?)
WITH rfm_base AS (
    SELECT
        c.customer_id,
        MAX(o.order_date)::DATE              AS last_purchase_date,
        COUNT(DISTINCT o.order_id)           AS frequency,
        SUM(oi.line_total)                   AS monetary
    FROM customers c
    JOIN orders o  ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY 1
),
rfm_scored AS (
    SELECT *,
        CURRENT_DATE - last_purchase_date    AS recency_days,
        NTILE(5) OVER (ORDER BY (CURRENT_DATE - last_purchase_date) DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency    ASC)  AS f_score,
        NTILE(5) OVER (ORDER BY monetary     ASC)  AS m_score
    FROM rfm_base
),
segmented AS (
    SELECT *,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
            ELSE 'Potential Loyalist'
        END AS rfm_segment
    FROM rfm_scored
)
SELECT
    rfm_segment,
    COUNT(*)                                AS customer_count,
    ROUND(AVG(monetary), 2)                AS avg_spend,
    ROUND(AVG(frequency), 1)               AS avg_orders,
    ROUND(AVG(recency_days), 0)            AS avg_days_since_purchase
FROM segmented
GROUP BY 1
ORDER BY avg_spend DESC;


-- 2.3 Customer lifetime value (CLV) ranking with DENSE_RANK
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name           AS customer_name,
    c.loyalty_tier,
    c.state,
    COUNT(DISTINCT o.order_id)                   AS total_orders,
    ROUND(SUM(oi.line_total), 2)                 AS lifetime_value,
    ROUND(AVG(oi.line_total), 2)                 AS avg_order_value,
    DENSE_RANK() OVER (ORDER BY SUM(oi.line_total) DESC)  AS clv_rank
FROM customers c
JOIN orders o  ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2, 3, 4
ORDER BY lifetime_value DESC
LIMIT 20;


-- ============================================================
-- SECTION 3: TOP PRODUCTS & STORES
-- ============================================================

-- 3.1 Top 10 products by revenue with category context
SELECT
    p.product_id,
    p.product_name,
    cat.category_name,
    p.brand,
    SUM(oi.quantity)                         AS units_sold,
    ROUND(SUM(oi.line_total), 2)             AS total_revenue,
    ROUND(AVG(oi.unit_price), 2)             AS avg_selling_price,
    ROUND(SUM(oi.line_total - oi.quantity * p.cost_price), 2) AS gross_profit,
    ROUND(
        SUM(oi.line_total - oi.quantity * p.cost_price)
        / NULLIF(SUM(oi.line_total), 0) * 100, 2
    )                                        AS margin_pct
FROM order_items oi
JOIN orders   o   ON oi.order_id   = o.order_id
JOIN products p   ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2, 3, 4
ORDER BY total_revenue DESC
LIMIT 10;


-- 3.2 Product performance with percentile rank
WITH product_revenue AS (
    SELECT
        p.product_name,
        SUM(oi.line_total) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY 1
)
SELECT
    product_name,
    ROUND(revenue, 2)                                  AS revenue,
    ROUND(PERCENT_RANK() OVER (ORDER BY revenue) * 100, 1) AS percentile
FROM product_revenue
ORDER BY revenue DESC;


-- 3.3 Store performance leaderboard
SELECT
    s.store_id,
    s.store_name,
    s.city,
    s.region,
    s.store_size,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    COUNT(DISTINCT o.customer_id)            AS unique_customers,
    ROUND(SUM(oi.line_total), 2)             AS total_revenue,
    ROUND(AVG(oi.line_total), 2)             AS avg_order_value,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2, 3, 4, 5
ORDER BY total_revenue DESC;


-- 3.4 Region-level sales with ROLLUP (subtotals + grand total)
SELECT
    COALESCE(s.region, '** GRAND TOTAL **')  AS region,
    COALESCE(s.store_name, 'All Stores')     AS store,
    ROUND(SUM(oi.line_total), 2)             AS revenue,
    COUNT(DISTINCT o.order_id)               AS orders
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY ROLLUP(s.region, s.store_name)
ORDER BY s.region NULLS LAST, s.store_name NULLS LAST;


-- ============================================================
-- SECTION 4: DISCOUNT PERFORMANCE
-- ============================================================

-- 4.1 Revenue with vs without discount
SELECT
    CASE WHEN oi.discount_pct > 0 THEN 'Discounted' ELSE 'Full Price' END AS price_type,
    COUNT(DISTINCT o.order_id)               AS orders,
    SUM(oi.quantity)                         AS units_sold,
    ROUND(SUM(oi.line_total), 2)             AS net_revenue,
    ROUND(AVG(oi.discount_pct), 2)           AS avg_discount_pct,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) AS avg_gross_order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1
ORDER BY 1;


-- 4.2 Promotion effectiveness (which promos drove most revenue?)
SELECT
    p.promo_name,
    p.promo_type,
    p.discount_pct,
    COUNT(DISTINCT o.order_id)               AS orders_using_promo,
    ROUND(SUM(oi.line_total), 2)             AS net_revenue,
    -- Revenue that was "given away" as discount
    ROUND(SUM(oi.quantity * oi.unit_price * oi.discount_pct / 100), 2) AS discount_given,
    ROUND(
        SUM(oi.quantity * oi.unit_price * oi.discount_pct / 100)
        / NULLIF(SUM(oi.quantity * oi.unit_price), 0) * 100, 2
    )                                        AS effective_discount_rate
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN promotions p   ON o.promo_id  = p.promo_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2, 3
ORDER BY net_revenue DESC;


-- 4.3 Discount elasticity: did discounts increase volume?
WITH disc_buckets AS (
    SELECT
        CASE
            WHEN oi.discount_pct = 0         THEN '0% — No discount'
            WHEN oi.discount_pct <= 10        THEN '1–10%'
            WHEN oi.discount_pct <= 20        THEN '11–20%'
            WHEN oi.discount_pct <= 30        THEN '21–30%'
            ELSE                                   '31%+'
        END                                  AS discount_bucket,
        oi.discount_pct,
        oi.quantity,
        oi.line_total
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
)
SELECT
    discount_bucket,
    COUNT(*)                                 AS line_items,
    ROUND(AVG(quantity), 2)                  AS avg_qty_per_line,
    ROUND(SUM(line_total), 2)                AS total_revenue
FROM disc_buckets
GROUP BY 1
ORDER BY MIN(discount_pct);


-- ============================================================
-- SECTION 5: SEASONAL PATTERNS
-- ============================================================

-- 5.1 Revenue by day of week (which days perform best?)
SELECT
    TO_CHAR(o.order_date, 'Day')             AS day_of_week,
    EXTRACT(DOW FROM o.order_date)           AS dow_num,
    COUNT(DISTINCT o.order_id)               AS orders,
    ROUND(SUM(oi.line_total), 2)             AS revenue,
    ROUND(AVG(oi.line_total), 2)             AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2
ORDER BY 2;


-- 5.2 Revenue by month (seasonal heatmap data)
SELECT
    EXTRACT(YEAR  FROM o.order_date)         AS year,
    TO_CHAR(o.order_date, 'Month')           AS month_name,
    EXTRACT(MONTH FROM o.order_date)         AS month_num,
    ROUND(SUM(oi.line_total), 2)             AS revenue,
    COUNT(DISTINCT o.order_id)               AS orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1, 2, 3
ORDER BY 1, 3;


-- 5.3 Category sales by season
WITH seasonal AS (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM o.order_date) IN (12,1,2)  THEN 'Winter'
            WHEN EXTRACT(MONTH FROM o.order_date) IN (3,4,5)   THEN 'Spring'
            WHEN EXTRACT(MONTH FROM o.order_date) IN (6,7,8)   THEN 'Summer'
            ELSE                                                     'Autumn'
        END                                  AS season,
        cat.category_name,
        SUM(oi.line_total)                   AS revenue
    FROM order_items oi
    JOIN orders   o   ON oi.order_id   = o.order_id
    JOIN products p   ON oi.product_id = p.product_id
    JOIN categories cat ON p.category_id = cat.category_id
    WHERE o.order_status = 'Completed'
      AND cat.parent_id IS NULL   -- top-level categories only
    GROUP BY 1, 2
)
SELECT
    season,
    category_name,
    ROUND(revenue, 2)                        AS revenue,
    RANK() OVER (PARTITION BY season ORDER BY revenue DESC) AS rank_in_season
FROM seasonal
ORDER BY
    CASE season WHEN 'Spring' THEN 1 WHEN 'Summer' THEN 2
                WHEN 'Autumn' THEN 3 ELSE 4 END,
    rank_in_season;


-- ============================================================
-- SECTION 6: BONUS — ADVANCED TECHNIQUES
-- ============================================================

-- 6.1 Customer cohort retention
-- Which signup-month cohorts are still buying 6 months later?
WITH first_orders AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
),
orders_with_cohort AS (
    SELECT
        o.customer_id,
        fo.cohort_month,
        DATE_TRUNC('month', o.order_date)    AS order_month,
        EXTRACT(YEAR  FROM AGE(DATE_TRUNC('month', o.order_date), fo.cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), fo.cohort_month)) AS months_since_first
    FROM orders o
    JOIN first_orders fo ON o.customer_id = fo.customer_id
    WHERE o.order_status = 'Completed'
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')         AS cohort,
    months_since_first                       AS month_number,
    COUNT(DISTINCT customer_id)              AS active_customers
FROM orders_with_cohort
GROUP BY 1, 2
ORDER BY 1, 2;


-- 6.2 Running total and percentage of total (pivot-style)
WITH category_revenue AS (
    SELECT
        cat.category_name,
        ROUND(SUM(oi.line_total), 2) AS revenue
    FROM order_items oi
    JOIN orders   o   ON oi.order_id   = o.order_id
    JOIN products p   ON oi.product_id = p.product_id
    JOIN categories cat ON p.category_id = cat.category_id
    WHERE o.order_status = 'Completed'
      AND cat.parent_id IS NULL
    GROUP BY 1
)
SELECT
    category_name,
    revenue,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2)          AS pct_of_total,
    ROUND(SUM(revenue) OVER (ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING), 2) AS running_total
FROM category_revenue
ORDER BY revenue DESC;


-- 6.3 Return rate by product (identify problem products)
SELECT
    p.product_name,
    cat.category_name,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Completed' THEN o.order_id END) AS completed_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Returned'  THEN o.order_id END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_status = 'Returned' THEN o.order_id END)::NUMERIC
        / NULLIF(COUNT(DISTINCT o.order_id), 0) * 100, 2
    )                                                        AS return_rate_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.order_status IN ('Completed', 'Returned')
GROUP BY 1, 2
HAVING COUNT(DISTINCT o.order_id) >= 3  -- only products with meaningful data
ORDER BY return_rate_pct DESC;


-- 6.4 Channel performance breakdown (In-Store vs Online vs Mobile)
SELECT
    o.channel,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    COUNT(DISTINCT o.customer_id)            AS unique_customers,
    ROUND(SUM(oi.line_total), 2)             AS revenue,
    ROUND(AVG(oi.line_total), 2)             AS avg_order_value,
    ROUND(SUM(o.shipping_cost), 2)           AS total_shipping_cost
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY 1
ORDER BY revenue DESC;
