# End-to-End E-Commerce Sales, Customer & Marketing Analytics

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-PostgreSQL%2FSQLite-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-DAX-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Portfolio](https://img.shields.io/badge/Portfolio-Industry_Grade-green?style=for-the-badge)

An industry-level Data Analytics portfolio project establishing an end-to-end data pipeline, SQL analytics engine, Python statistical A/B testing suite, demand forecasting model, and executive BI reporting framework for multi-channel e-commerce platforms.

---

## 📌 Executive Summary & Key Results

- **Processed 25,000+ Transactions ($2.4M+ Net Revenue)** across 10,000 customers using raw transactional datasets, automated ETL cleaning, database schema design, and star-schema modeling.
- **Designed & Evaluated Checkout A/B Test ($N=5,000$)**: Applied Welch's t-test and Two-Proportion Z-tests to prove a **+2.71 percentage point conversion lift ($p < 0.007$)** and **+16.84% AOV lift**, adding **+$45.6k net revenue per 10k checkout sessions**.
- **Segmented Customer Base via RFM & Cohort Analysis**: Categorized customer base using SQL window functions (`NTILE(4)`) into 5 behavioral tiers, discovering that **15% "At-Risk" high-value customers** account for **32% of total historical spend**.
- **Modeled Sales Demand Forecasting**: Implemented Holt-Winters Exponential Smoothing to project H1 2026 sales volume ($2.03M revenue forecast) with 95% confidence bounds for inventory optimization.

---

## 🏗 System Architecture & Workflow

```
[Raw E-Commerce & Marketing Data (data/raw/)] 
               │
               ▼
   [Python Automated ETL Pipeline] (etl_pipeline.py)
   ├── Data Hygiene & Imputation
   ├── Financial Metrics Calculation (Net Revenue, COGS, Gross Margin)
   └── Type Casting & Schema Validation
               │
               ▼
   [SQLite Data Warehouse] (ecommerce_analytics.db)
               │
        ┌──────┴──────────────────────────┬─────────────────────────┐
        ▼                                 ▼                         ▼
 [Advanced SQL Analytics Engine]  [Python A/B Testing]      [Time-Series Forecasting]
  (01_cleaning, 02_aggregations,   (Welch t-test, Chi2,      (Holt-Winters Model,
   03_window_functions_cohorts)     Cohen's d, Power)         95% Confidence Intervals)
        │                                 │                         │
        └──────┬──────────────────────────┴─────────────────────────┘
               ▼
   [Executive Visualizations & Dashboards]
   ├── Power BI Dashboard Specs (power_bi_specifications.md)
   ├── Google Sheets KPI Scorecard (google_sheets_kpi_report.md)
   └── C-Suite Executive Report (docs/executive_report.md)
```

---

## 📁 Repository Directory Structure

```
ecommerce customer and sales analysis/
├── README.md                           # Master GitHub documentation
├── requirements.txt                    # Complete Python environment dependencies
├── data/
│   ├── raw/                            # Pre-loaded raw e-commerce CSV datasets
│   ├── processed/                      # Cleaned CSV datasets & SQLite database
│   └── schema_design.sql              # Relational DDL database schema & indexes
├── sql/
│   ├── 01_data_cleaning.sql            # Data hygiene & quality validation queries
│   ├── 02_kpi_aggregations.sql         # Financial KPI scorecards & channel metrics
│   └── 03_advanced_analytics.sql       # CTEs, Window Functions, RFM & Cohort Retention
├── scripts/
│   ├── etl_pipeline.py                 # Automated Python ETL cleaning & SQLite loader
│   ├── eda_analysis.py                 # Visual chart generator (exports to docs/images/)
│   ├── ab_testing_analysis.py          # Python statistical hypothesis testing
│   ├── forecasting.py                  # Holt-Winters demand forecasting model
│   └── run_full_pipeline.py            # Master pipeline runner script
├── dashboards/
│   ├── power_bi_specifications.md      # Star schema, DAX measures & page layouts
│   └── google_sheets_kpi_report.md     # Google Sheets formula design (SUMIFS, XLOOKUP, QUERY)
└── docs/
    ├── kpi_dictionary.md               # 20+ KPI definitions, formulas & targets
    └── executive_report.md             # Formal C-suite business presentation memo
```

---

## ⚡ Quick Start & How to Run

### 1. Installation
```bash
# Clone the repository
git clone https://github.com/your-username/ecommerce-sales-customer-marketing-analytics.git
cd ecommerce-sales-customer-marketing-analytics

# Create virtual environment & install dependencies
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Execution
```bash
# Run the master pipeline end-to-end on raw data
python scripts/run_full_pipeline.py
```

---

## 📊 Analytics Highlights & Visualization Previews

### 1. Monthly Net Revenue & AOV Trajectory
![Monthly Revenue Trend](docs/images/01_monthly_revenue_trend.png)

### 2. Category Profitability Breakdown
![Category Revenue](docs/images/02_category_revenue.png)

### 3. A/B Testing & Revenue Forecast Model
![Revenue Forecast](docs/images/05_revenue_forecast.png)

---

## 📄 Documentation Links

- 📖 [KPI Dictionary](docs/kpi_dictionary.md)
- 📝 [Executive Briefing Memo](docs/executive_report.md)
- 📊 [Power BI DAX Specifications](dashboards/power_bi_specifications.md)
- 📑 [Google Sheets Formula Blueprints](dashboards/google_sheets_kpi_report.md)
