-- =============================================================================
-- E-Commerce Analytics Database Schema Definition (DDL)
-- Database Target: SQLite / PostgreSQL / ANSI SQL
-- Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics
-- =============================================================================

-- Drop tables if they already exist to ensure idempotent builds
DROP TABLE IF EXISTS ab_test_experiment;
DROP TABLE IF EXISTS marketing_campaigns;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    join_date DATE NOT NULL,
    region TEXT NOT NULL,
    state TEXT NOT NULL,
    city TEXT NOT NULL,
    acquisition_channel TEXT NOT NULL, -- Paid Search, Organic, Social, Referral, Direct
    customer_segment TEXT NOT NULL    -- Consumer, Corporate, Small Business
);

-- 2. Products Table
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    category_name TEXT NOT NULL,
    sub_category TEXT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    weight_g INT,
    length_cm INT
);

-- 3. Orders Table
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_status TEXT NOT NULL, -- delivered, shipped, canceled, processing
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_timestamp DATETIME,
    payment_method TEXT NOT NULL, -- credit_card, boleto, voucher, debit_card
    shipping_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Order Items Table
CREATE TABLE order_items (
    order_item_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    seller_id TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. Marketing Campaigns Table
CREATE TABLE marketing_campaigns (
    campaign_id TEXT PRIMARY KEY,
    campaign_name TEXT NOT NULL,
    channel TEXT NOT NULL, -- Google Ads, Meta Ads, Email, Influencer, Affiliate
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    total_spend DECIMAL(10, 2) NOT NULL,
    impressions INT NOT NULL,
    clicks INT NOT NULL,
    conversions INT NOT NULL
);

-- 6. A/B Testing Experiment Table (Discount Strategy: 15% Off Cart vs Free Shipping Threshold)
CREATE TABLE ab_test_experiment (
    user_id TEXT PRIMARY KEY,
    variant TEXT NOT NULL, -- 'Control_15PercentOff' vs 'Treatment_FreeShippingThreshold'
    exposed_at DATETIME NOT NULL,
    converted INT NOT NULL CHECK(converted IN (0, 1)),
    total_order_value DECIMAL(10, 2) DEFAULT 0.00,
    discount_offered DECIMAL(10, 2) DEFAULT 0.00
);

-- Indexes for Query Performance Optimization
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_purchase_time ON orders(order_purchase_timestamp);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_customers_region ON customers(region);
CREATE INDEX idx_ab_test_variant ON ab_test_experiment(variant);
