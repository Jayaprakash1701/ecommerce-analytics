-- =============================================================================
-- SQL Script 02: Core Business KPI Aggregations & Reporting Queries
-- Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics
-- Target Database: SQLite / PostgreSQL / ANSI SQL
-- Skill / ATS Keywords: Business Metrics, Aggregations, GROUP BY, Financial Ratios, Channel ROAS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Executive Summary KPI Scorecard
-- Objective: Calculate high-level financial health metrics across entire dataset
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(oi.net_revenue), 2) AS gross_sales,
    ROUND(SUM(oi.discount_amount), 2) AS total_discounts,
    ROUND(SUM(oi.net_revenue), 2) AS total_net_revenue,
    ROUND(SUM(oi.gross_profit), 2) AS total_gross_profit,
    ROUND((SUM(oi.gross_profit) / NULLIF(SUM(oi.net_revenue), 0)) * 100, 2) AS gross_margin_pct,
    ROUND(SUM(oi.net_revenue) / COUNT(DISTINCT o.order_id), 2) AS average_order_value_aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- -----------------------------------------------------------------------------
-- 2. Monthly Revenue, Order Volume & AOV Trends (Time-Series Aggregation)
-- Objective: Track revenue trajectory, seasonality spikes, and month-over-month growth
-- -----------------------------------------------------------------------------
WITH MonthlySales AS (
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS year_month,
        COUNT(DISTINCT o.order_id) AS monthly_orders,
        COUNT(DISTINCT o.customer_id) AS active_buyers,
        ROUND(SUM(oi.net_revenue), 2) AS monthly_net_revenue,
        ROUND(SUM(oi.gross_profit), 2) AS monthly_gross_profit
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT 
    year_month,
    monthly_orders,
    active_buyers,
    monthly_net_revenue,
    ROUND(monthly_net_revenue / monthly_orders, 2) AS monthly_aov,
    monthly_gross_profit,
    ROUND((monthly_gross_profit / monthly_net_revenue) * 100, 2) AS margin_pct,
    ROUND(
        (monthly_net_revenue - LAG(monthly_net_revenue, 1) OVER (ORDER BY year_month)) 
        / NULLIF(LAG(monthly_net_revenue, 1) OVER (ORDER BY year_month), 0) * 100, 
        2
    ) AS mom_revenue_growth_pct
FROM MonthlySales
ORDER BY year_month;


-- -----------------------------------------------------------------------------
-- 3. Category & Sub-Category Sales & Profitability Analysis
-- Objective: Identify high-volume vs high-margin product categories
-- -----------------------------------------------------------------------------
SELECT 
    p.category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(1) AS units_sold,
    ROUND(SUM(oi.net_revenue), 2) AS category_revenue,
    ROUND(SUM(oi.gross_profit), 2) AS category_profit,
    ROUND((SUM(oi.gross_profit) / NULLIF(SUM(oi.net_revenue), 0)) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(oi.net_revenue) / SUM(1), 2) AS average_unit_selling_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category_name
ORDER BY category_revenue DESC;


-- -----------------------------------------------------------------------------
-- 4. Customer Acquisition Channel Performance (CAC & Revenue Contribution)
-- Objective: Evaluate effectiveness of acquisition channels
-- -----------------------------------------------------------------------------
SELECT 
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_acquired_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.net_revenue), 2) AS total_channel_revenue,
    ROUND(SUM(oi.net_revenue) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_acquired_customer
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'delivered'
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.acquisition_channel
ORDER BY total_channel_revenue DESC;


-- -----------------------------------------------------------------------------
-- 5. Marketing Campaign Efficiency: ROAS, CPA, and CTR Analysis
-- Objective: Quantify Return on Ad Spend (ROAS) per campaign
-- -----------------------------------------------------------------------------
SELECT 
    campaign_name,
    channel,
    total_spend,
    impressions,
    clicks,
    conversions,
    ctr_pct,
    conversion_rate_pct,
    cac_per_conversion AS cpa_cost_per_acquisition
FROM marketing_campaigns
ORDER BY total_spend DESC;
