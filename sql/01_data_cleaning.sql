-- =============================================================================
-- SQL Script 01: Data Cleaning, Formatting & Data Quality Validation
-- Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics
-- Target Database: SQLite / PostgreSQL / ANSI SQL
-- Skill / ATS Keywords: Data Hygiene, Deduplication, NULL Imputation, Type Casting, Data Validation
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Identify & Handle Missing / Null Values in Customers Table
-- Objective: Detect missing regions and acquisition channels
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN region IS NULL OR region = '' THEN 1 ELSE 0 END) AS null_regions,
    SUM(CASE WHEN acquisition_channel IS NULL OR acquisition_channel = '' THEN 1 ELSE 0 END) AS null_channels
FROM customers;

-- Cleaned View: Impute missing regions as 'Unknown' and standardize text casing
CREATE VIEW IF NOT EXISTS v_clean_customers AS
SELECT 
    customer_id,
    customer_unique_id,
    DATE(join_date) AS join_date,
    COALESCE(NULLIF(region, ''), 'Unknown') AS region,
    UPPER(SUBSTR(acquisition_channel, 1, 1)) || LOWER(SUBSTR(acquisition_channel, 2)) AS acquisition_channel,
    customer_segment
FROM customers;


-- -----------------------------------------------------------------------------
-- 2. Detect Duplicate Orders or Order Items
-- Objective: Ensure primary key integrity before running financial aggregations
-- -----------------------------------------------------------------------------
WITH DuplicateCheck AS (
    SELECT 
        order_id,
        COUNT(*) AS row_cnt
    FROM orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
SELECT 
    COUNT(*) AS duplicate_order_ids 
FROM DuplicateCheck;


-- -----------------------------------------------------------------------------
-- 3. Financial Data Sanity & Outlier Detection
-- Objective: Verify no negative prices, invalid zero items, or impossible delivery timestamps
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS anomalous_order_items
FROM order_items
WHERE price <= 0 OR discount_amount < 0;

SELECT 
    COUNT(*) AS invalid_delivery_dates
FROM orders
WHERE order_delivered_timestamp < order_purchase_timestamp;
