"""
Master Analytics Pipeline Runner Script
Project: End-to-End E-Commerce Sales, Customer & Marketing Analytics

Runs the end-to-end data analytics workflow using pre-existing raw data in `data/`:
1. Execute Python ETL Pipeline & SQLite Database Load
2. Execute Exploratory Data Analysis & Chart Generation
3. Run A/B Testing Statistical Hypothesis Tests
4. Generate Time-Series Demand Forecasts
"""

import sys
import time
from etl_pipeline import run_etl
from eda_analysis import run_eda
from ab_testing_analysis import run_ab_test_analysis
from forecasting import run_forecasting


def main():
    start_time = time.time()
    print("=============================================================================")
    print(" STARTING END-TO-END E-COMMERCE ANALYTICS PIPELINE")
    print("=============================================================================\n")

    # Step 1: Run ETL Pipeline on Raw Data in data/
    print("[+] Step 1: Running ETL Pipeline on raw data...")
    run_etl()
    print("")

    # Step 2: Exploratory Data Analysis
    print("[+] Step 2: Running Exploratory Data Analysis & Visualizations...")
    run_eda()
    print("")

    # Step 3: A/B Testing Analysis
    print("[+] Step 3: Executing A/B Testing Statistical Analysis...")
    run_ab_test_analysis()
    print("")

    # Step 4: Revenue & Demand Forecasting
    print("[+] Step 4: Generating Revenue & Demand Forecasts...")
    run_forecasting()
    print("")

    elapsed = time.time() - start_time
    print("=============================================================================")
    print(f" [OK] FULL PIPELINE COMPLETED SUCCESSFULLY IN {elapsed:.2f} SECONDS!")
    print("=============================================================================")


if __name__ == "__main__":
    main()
