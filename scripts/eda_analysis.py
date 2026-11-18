"""
Exploratory Data Analysis (EDA) & Visualization Suite
Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics

This script queries SQLite database `data/ecommerce_analytics.db` to perform EDA:
1. Sales trend analysis & seasonality curves
2. Product category gross margin distribution
3. Marketing channel conversion rates & ROAS
4. RFM customer segment distribution
5. Saves static chart images to `docs/`
"""

import os
import sqlite3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Set Matplotlib / Seaborn aesthetic style
sns.set_theme(style="whitegrid")
plt.rcParams.update({
    "font.size": 12,
    "axes.labelsize": 14,
    "axes.titlesize": 16,
    "xtick.labelsize": 11,
    "ytick.labelsize": 11,
    "figure.titlesize": 18
})

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "data", "ecommerce_analytics.db")
IMG_DIR = os.path.join(BASE_DIR, "docs")


def run_eda():
    print("[+] Executing Exploratory Data Analysis (EDA)...")
    conn = sqlite3.connect(DB_PATH)

    # 1. Monthly Revenue & AOV Trend
    query_monthly = """
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS year_month,
        SUM(oi.net_revenue) AS monthly_revenue,
        COUNT(DISTINCT o.order_id) AS monthly_orders,
        SUM(oi.net_revenue) / COUNT(DISTINCT o.order_id) AS aov
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
    ORDER BY 1;
    """
    df_monthly = pd.read_sql_query(query_monthly, conn)

    fig, ax1 = plt.subplots(figsize=(12, 6))
    ax2 = ax1.twinx()

    sns.lineplot(data=df_monthly, x="year_month", y="monthly_revenue", ax=ax1, color="#1f77b4", marker="o", linewidth=2.5, label="Net Revenue ($)")
    sns.lineplot(data=df_monthly, x="year_month", y="aov", ax=ax2, color="#ff7f0e", marker="s", linewidth=2.5, linestyle="--", label="AOV ($)")

    ax1.set_title("Monthly Revenue Trajectory & Average Order Value (AOV)", pad=15)
    ax1.set_xlabel("Year-Month")
    ax1.set_ylabel("Net Revenue ($)", color="#1f77b4")
    ax2.set_ylabel("Average Order Value ($)", color="#ff7f0e")
    ax1.tick_params(axis='x', rotation=45)
    ax1.grid(True, linestyle=":", alpha=0.6)

    fig.tight_layout()
    plt.savefig(os.path.join(IMG_DIR, "01_monthly_revenue_trend.png"), dpi=300)
    plt.close()
    print("  [OK] Generated 01_monthly_revenue_trend.png")

    # 2. Product Category Profitability Bar Chart
    query_cat = """
    SELECT 
        p.category_name,
        SUM(oi.net_revenue) AS category_revenue,
        SUM(oi.gross_profit) AS category_profit,
        (SUM(oi.gross_profit) / SUM(oi.net_revenue)) * 100 AS margin_pct
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
    ORDER BY category_revenue DESC;
    """
    df_cat = pd.read_sql_query(query_cat, conn)

    plt.figure(figsize=(10, 6))
    bars = sns.barplot(data=df_cat, x="category_revenue", y="category_name", palette="Blues_r")
    plt.title("Revenue Contribution by Product Category", pad=15)
    plt.xlabel("Total Net Revenue ($)")
    plt.ylabel("Category")

    for bar in bars.patches:
        val = f"${bar.get_width():,.0f}"
        plt.text(bar.get_width() + 5000, bar.get_y() + bar.get_height()/2, val, ha="left", va="center", fontsize=10)

    plt.tight_layout()
    plt.savefig(os.path.join(IMG_DIR, "02_category_revenue.png"), dpi=300)
    plt.close()
    print("  [OK] Generated 02_category_revenue.png")

    # 3. Marketing Campaign CPA vs Conversion Rate
    query_mkt = "SELECT campaign_name, channel, total_spend, conversions, ctr_pct, conversion_rate_pct, cac_per_conversion FROM marketing_campaigns;"
    df_mkt = pd.read_sql_query(query_mkt, conn)

    plt.figure(figsize=(10, 6))
    sns.scatterplot(
        data=df_mkt, x="cac_per_conversion", y="conversion_rate_pct", hue="channel", size="total_spend",
        sizes=(100, 500), palette="Set2", alpha=0.85
    )
    plt.title("Marketing Efficiency: CPA vs Conversion Rate by Channel", pad=15)
    plt.xlabel("Cost Per Acquisition / CPA ($)")
    plt.ylabel("Conversion Rate (%)")
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')

    plt.tight_layout()
    plt.savefig(os.path.join(IMG_DIR, "03_marketing_efficiency.png"), dpi=300)
    plt.close()
    print("  [OK] Generated 03_marketing_efficiency.png")

    # 4. Acquisition Channel Customer Distribution Pie Chart
    query_channel = """
    SELECT acquisition_channel, COUNT(customer_id) AS customer_cnt
    FROM customers
    GROUP BY 1
    ORDER BY customer_cnt DESC;
    """
    df_channel = pd.read_sql_query(query_channel, conn)

    plt.figure(figsize=(8, 8))
    plt.pie(df_channel["customer_cnt"], labels=df_channel["acquisition_channel"], autopct="%1.1f%%", colors=sns.color_palette("pastel"), startangle=140)
    plt.title("Customer Acquisition Channel Mix", pad=15)

    plt.tight_layout()
    plt.savefig(os.path.join(IMG_DIR, "04_channel_acquisition_mix.png"), dpi=300)
    plt.close()
    print("  [OK] Generated 04_channel_acquisition_mix.png")

    conn.close()
    print("[OK] EDA Visualizations completed successfully.")


if __name__ == "__main__":
    run_eda()
