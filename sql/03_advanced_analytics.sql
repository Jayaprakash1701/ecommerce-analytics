-- =============================================================================
-- SQL Script 03: Advanced Analytics, CTEs, Window Functions & Customer Cohorts
-- Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics
-- Target Database: SQLite / PostgreSQL / ANSI SQL
-- Skill / ATS Keywords: Window Functions, CTEs, RFM Segmentation, Cohort Retention, Rolling Averages, DENSE_RANK
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Customer RFM Segmentation (Recency, Frequency, Monetary)
-- Objective: Segment customer base into actionable behavioral tiers using NTILE()
-- Reference Anchor Date: 2026-01-01
-- -----------------------------------------------------------------------------
WITH CustomerMetrics AS (
    SELECT 
        c.customer_id,
        c.customer_segment,
        c.region,
        CAST((JULIANDAY('2026-01-01') - JULIANDAY(MAX(o.order_purchase_timestamp))) AS INT) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.net_revenue), 2) AS monetary_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_segment, c.region
),
RFMScores AS (
    SELECT 
        customer_id,
        customer_segment,
        region,
        recency_days,
        frequency,
        monetary_value,
        -- Higher recency_days = worse score, so reverse order
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM CustomerMetrics
),
CombinedScores AS (
    SELECT 
        customer_id,
        customer_segment,
        region,
        recency_days,
        frequency,
        monetary_value,
        r_score,
        f_score,
        m_score,
        (r_score * 100 + f_score * 10 + m_score) AS rfm_combined,
        CASE 
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal Customers'
            WHEN r_score >= 2 AND f_score >= 2 THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk (High Value)'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Hibernating / Lost'
            ELSE 'Needs Attention'
        END AS rfm_customer_tier
    FROM RFMScores
)
SELECT 
    rfm_customer_tier,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary_value), 2) AS avg_monetary_spend,
    ROUND(SUM(monetary_value), 2) AS total_segment_revenue
FROM CombinedScores
GROUP BY rfm_customer_tier
ORDER BY total_segment_revenue DESC;


-- -----------------------------------------------------------------------------
-- 2. Monthly Cohort Retention Analysis Matrix
-- Objective: Track customer re-purchase rates by signup cohort over time
-- -----------------------------------------------------------------------------
WITH FirstPurchase AS (
    SELECT 
        customer_id,
        STRFTIME('%Y-%m', MIN(order_purchase_timestamp)) AS cohort_month
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),
UserActivity AS (
    SELECT 
        o.customer_id,
        fp.cohort_month,
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS activity_month,
        (
            (CAST(STRFTIME('%Y', o.order_purchase_timestamp) AS INT) - CAST(STRFTIME('%Y', fp.cohort_month) AS INT)) * 12 +
            (CAST(STRFTIME('%m', o.order_purchase_timestamp) AS INT) - CAST(STRFTIME('%m', fp.cohort_month) AS INT))
        ) AS month_number
    FROM orders o
    JOIN FirstPurchase fp ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT 
    cohort_month,
    COUNT(DISTINCT CASE WHEN month_number = 0 THEN customer_id END) AS cohort_size,
    COUNT(DISTINCT CASE WHEN month_number = 1 THEN customer_id END) AS m1_users,
    COUNT(DISTINCT CASE WHEN month_number = 2 THEN customer_id END) AS m2_users,
    COUNT(DISTINCT CASE WHEN month_number = 3 THEN customer_id END) AS m3_users,
    COUNT(DISTINCT CASE WHEN month_number = 6 THEN customer_id END) AS m6_users,
    ROUND(CAST(COUNT(DISTINCT CASE WHEN month_number = 1 THEN customer_id END) AS FLOAT) / COUNT(DISTINCT CASE WHEN month_number = 0 THEN customer_id END) * 100, 2) AS m1_retention_pct,
    ROUND(CAST(COUNT(DISTINCT CASE WHEN month_number = 3 THEN customer_id END) AS FLOAT) / COUNT(DISTINCT CASE WHEN month_number = 0 THEN customer_id END) * 100, 2) AS m3_retention_pct
FROM UserActivity
GROUP BY cohort_month
ORDER BY cohort_month;


-- -----------------------------------------------------------------------------
-- 3. Top 3 Revenue-Generating Products per Category using DENSE_RANK()
-- Objective: Rank top performing products per catalog category
-- -----------------------------------------------------------------------------
WITH ProductRevenue AS (
    SELECT 
        p.category_name,
        p.product_id,
        p.sub_category,
        ROUND(SUM(oi.net_revenue), 2) AS total_revenue,
        SUM(1) AS units_sold,
        DENSE_RANK() OVER (PARTITION BY p.category_name ORDER BY SUM(oi.net_revenue) DESC) AS category_rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.category_name, p.product_id, p.sub_category
)
SELECT 
    category_name,
    category_rank,
    product_id,
    sub_category,
    total_revenue,
    units_sold
FROM ProductRevenue
WHERE category_rank <= 3
ORDER BY category_name, category_rank;


-- -----------------------------------------------------------------------------
-- 4. Daily Moving Averages & Cumulative Sales Window Functions
-- Objective: Smooth out daily noise with 7-Day & 30-Day rolling revenue averages
-- -----------------------------------------------------------------------------
WITH DailySales AS (
    SELECT 
        DATE(o.order_purchase_timestamp) AS order_date,
        ROUND(SUM(oi.net_revenue), 2) AS daily_revenue,
        COUNT(DISTINCT o.order_id) AS daily_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE(o.order_purchase_timestamp)
)
SELECT 
    order_date,
    daily_revenue,
    daily_orders,
    ROUND(AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7day_avg_revenue,
    ROUND(AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS rolling_30day_avg_revenue,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_running_total_revenue
FROM DailySales
ORDER BY order_date;
