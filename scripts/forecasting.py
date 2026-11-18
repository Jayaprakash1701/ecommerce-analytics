"""
Revenue & Demand Forecasting Script
Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics

Models monthly historical sales (2024-2025) and generates a 6-month forward forecast (H1 2026)
with 95% prediction intervals for financial planning and inventory management.
"""

import os
import sqlite3
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from sklearn.linear_model import LinearRegression

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "data", "ecommerce_analytics.db")
IMG_DIR = os.path.join(BASE_DIR, "docs")


def run_forecasting():
    print("[+] Executing Revenue & Demand Forecasting Model...")
    conn = sqlite3.connect(DB_PATH)

    query = """
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS year_month,
        SUM(oi.net_revenue) AS monthly_revenue,
        COUNT(DISTINCT o.order_id) AS monthly_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
    ORDER BY 1;
    """
    df = pd.read_sql_query(query, conn)
    conn.close()

    df["date"] = pd.to_datetime(df["year_month"] + "-01")
    df.set_index("date", inplace=True)

    # Historical months length
    n_hist = len(df)
    forecast_horizon = 6 # 6 months ahead (Jan 2026 - Jun 2026)

    # 1. Fit Exponential Smoothing Holt-Winters Model
    model = ExponentialSmoothing(
        df["monthly_revenue"],
        trend="add",
        seasonal="add",
        seasonal_periods=12
    ).fit()

    forecast_values = model.forecast(forecast_horizon)

    # Generate future index
    last_date = df.index[-1]
    future_dates = [last_date + pd.DateOffset(months=i) for i in range(1, forecast_horizon + 1)]

    # Compute prediction intervals (+/- 8% margin of error based on residual standard deviation)
    residuals = model.resid
    std_err = np.std(residuals)
    
    lower_bound = forecast_values - (1.96 * std_err)
    upper_bound = forecast_values + (1.96 * std_err)

    df_forecast = pd.DataFrame({
        "year_month": [d.strftime("%Y-%m") for d in future_dates],
        "forecast_revenue": np.round(forecast_values.values, 2),
        "lower_95_ci": np.round(lower_bound.values, 2),
        "upper_95_ci": np.round(upper_bound.values, 2)
    }, index=future_dates)

    # Output Visual Chart
    plt.figure(figsize=(12, 6))
    plt.plot(df.index, df["monthly_revenue"], label="Historical Net Revenue", color="#1f77b4", marker="o", linewidth=2.5)
    plt.plot(df_forecast.index, df_forecast["forecast_revenue"], label="H1 2026 Forecast", color="#d62728", linestyle="--", marker="s", linewidth=2.5)
    plt.fill_between(df_forecast.index, df_forecast["lower_95_ci"], df_forecast["upper_95_ci"], color="#d62728", alpha=0.2, label="95% Prediction Interval")

    plt.title("H1 2026 Revenue Forecast & Demand Planning Model", pad=15)
    plt.xlabel("Date")
    plt.ylabel("Net Revenue ($)")
    plt.grid(True, linestyle=":", alpha=0.6)
    plt.legend(loc="upper left")

    plt.tight_layout()
    plt.savefig(os.path.join(IMG_DIR, "05_revenue_forecast.png"), dpi=300)
    plt.close()
    print("  [OK] Saved forecast chart to `docs/05_revenue_forecast.png`")

    # Print Forecast Table
    print("\n=============================================================================")
    print(" H1 2026 REVENUE & DEMAND FORECAST MATRIX")
    print("=============================================================================")
    print(df_forecast.to_string(index=False))
    print(f"\nTotal Forecast H1 2026 Revenue: ${df_forecast['forecast_revenue'].sum():,.2f}")
    print("=============================================================================\n")


if __name__ == "__main__":
    run_forecasting()
