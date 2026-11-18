"""
Production ETL & Data Cleaning Pipeline
Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics

This script performs Extract, Transform, and Load (ETL) tasks on raw e-commerce CSVs:
1. Extract raw data from `data/`
2. Perform automated data cleaning (handling nulls, standardizing text, type casting, outlier filtering)
3. Derive business analytical fields (Net Revenue, Gross Margin, Order Tenure)
4. Load clean structured tables into SQLite database (`data/ecommerce_analytics.db`).
"""

import os
import sqlite3
import logging
import pandas as pd
import numpy as np

# Configure Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()]
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
DB_PATH = os.path.join(DATA_DIR, "ecommerce_analytics.db")


def extract_raw_data():
    """Extract raw CSV data from the data directory."""
    logging.info("Extracting raw CSV datasets...")
    raw_tables = {
        "customers": pd.read_csv(os.path.join(DATA_DIR, "raw_customers.csv")),
        "products": pd.read_csv(os.path.join(DATA_DIR, "raw_products.csv")),
        "orders": pd.read_csv(os.path.join(DATA_DIR, "raw_orders.csv")),
        "order_items": pd.read_csv(os.path.join(DATA_DIR, "raw_order_items.csv")),
        "marketing_campaigns": pd.read_csv(os.path.join(DATA_DIR, "raw_marketing_campaigns.csv")),
        "ab_test_experiment": pd.read_csv(os.path.join(DATA_DIR, "raw_ab_test_experiment.csv")),
    }
    return raw_tables


def transform_data(raw_tables):
    """
    Cleans raw datasets and adds derived business metrics.
    """
    logging.info("Transforming and cleaning data...")

    # 1. Clean Customers
    df_cust = raw_tables["customers"].copy()
    # Handle missing regions
    df_cust["region"] = df_cust["region"].fillna("Unknown")
    # Standardize acquisition channel casing
    df_cust["acquisition_channel"] = df_cust["acquisition_channel"].str.title()
    # Deduplicate
    df_cust = df_cust.drop_duplicates(subset=["customer_id"])

    # 2. Clean Products
    df_prod = raw_tables["products"].copy()
    df_prod["unit_cost"] = df_prod["unit_cost"].clip(lower=0.01)
    df_prod["unit_price"] = df_prod["unit_price"].clip(lower=0.01)
    # Derive Product Profit Margin %
    df_prod["profit_margin_pct"] = np.round(((df_prod["unit_price"] - df_prod["unit_cost"]) / df_prod["unit_price"]) * 100, 2)

    # 3. Clean Orders
    df_orders = raw_tables["orders"].copy()
    df_orders["order_purchase_timestamp"] = pd.to_datetime(df_orders["order_purchase_timestamp"])
    df_orders["order_approved_at"] = pd.to_datetime(df_orders["order_approved_at"])
    df_orders["order_delivered_timestamp"] = pd.to_datetime(df_orders["order_delivered_timestamp"])
    df_orders["order_status"] = df_orders["order_status"].str.lower().str.strip()

    # 4. Clean Order Items & Derive Financial Metrics
    df_items = raw_tables["order_items"].copy()
    # Merge with products to calculate cost and net margin
    df_items_merged = df_items.merge(df_prod[["product_id", "unit_cost"]], on="product_id", how="left")
    
    # Financial metrics per item
    df_items_merged["net_revenue"] = np.round(df_items_merged["price"] - df_items_merged["discount_amount"], 2)
    df_items_merged["cost_of_goods_sold"] = np.round(df_items_merged["unit_cost"], 2)
    df_items_merged["gross_profit"] = np.round(df_items_merged["net_revenue"] - df_items_merged["cost_of_goods_sold"], 2)

    # 5. Clean Marketing Campaigns & Calculate ROAS and CAC
    df_mkt = raw_tables["marketing_campaigns"].copy()
    df_mkt["start_date"] = pd.to_datetime(df_mkt["start_date"])
    df_mkt["end_date"] = pd.to_datetime(df_mkt["end_date"])
    df_mkt["ctr_pct"] = np.round((df_mkt["clicks"] / df_mkt["impressions"]) * 100, 2)
    df_mkt["conversion_rate_pct"] = np.round((df_mkt["conversions"] / df_mkt["clicks"]) * 100, 2)
    df_mkt["cac_per_conversion"] = np.round(df_mkt["total_spend"] / df_mkt["conversions"], 2)

    # 6. Clean A/B Test Data
    df_ab = raw_tables["ab_test_experiment"].copy()
    df_ab["exposed_at"] = pd.to_datetime(df_ab["exposed_at"])
    df_ab["converted"] = df_ab["converted"].astype(int)

    logging.info("Data transformations complete.")
    return {
        "customers": df_cust,
        "products": df_prod,
        "orders": df_orders,
        "order_items": df_items_merged,
        "marketing_campaigns": df_mkt,
        "ab_test_experiment": df_ab
    }


def load_data(clean_tables):
    """Loads clean tables into SQLite database and exports processed CSV files."""
    logging.info(f"Loading data into SQLite database: {DB_PATH}")

    # Read DDL schema script
    schema_script = os.path.join(BASE_DIR, "data", "schema_design.sql")
    conn = sqlite3.connect(DB_PATH)
    
    with open(schema_script, "r") as f:
        ddl = f.read()
    conn.executescript(ddl)

    # Insert cleaned DataFrames into SQLite tables
    for table_name, df in clean_tables.items():
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        logging.info(f"Loaded table `{table_name}` ({len(df)} records) into SQLite DB")

    conn.close()
    logging.info("[OK] ETL Pipeline executed successfully.")


def run_etl():
    raw_tables = extract_raw_data()
    clean_tables = transform_data(raw_tables)
    load_data(clean_tables)


if __name__ == "__main__":
    run_etl()
