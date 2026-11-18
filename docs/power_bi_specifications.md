# Power BI Dashboard Technical Specifications

**Project**: End-to-End E-Commerce Sales, Customer & Marketing Analytics  
**Target Tool**: Power BI Desktop / Service  
**Data Engine**: Import Mode (Connected to SQLite / Clean CSVs)  

---

## 1. Data Architecture & Star Schema Model

The Power BI data model follows a **Star Schema** centered around two fact tables (`fact_orders`, `fact_order_items`) and linked dimension tables.

```
                  +---------------------+
                  |   dim_customers     |
                  +---------------------+
                             |
                             | 1:N
                             v
+------------------+     +---------------------+     +---------------------+
|    dim_date      |---->|     fact_orders     |<----|   dim_payment_method|
+------------------+ 1:N +---------------------+ 1:N +---------------------+
                             |
                             | 1:N
                             v
+------------------+     +---------------------+     +---------------------+
|   dim_products   |---->|  fact_order_items   |<----|  dim_marketing      |
+------------------+ 1:N +---------------------+ 1:N +---------------------+
```

### Table Relationships
- `dim_date[Date]` (1) **--->** `fact_orders[order_purchase_timestamp]` (N) [Single Direction]
- `dim_customers[customer_id]` (1) **--->** `fact_orders[customer_id]` (N) [Single Direction]
- `dim_products[product_id]` (1) **--->** `fact_order_items[product_id]` (N) [Single Direction]
- `fact_orders[order_id]` (1) **--->** `fact_order_items[order_id]` (N) [Single Direction]

---

## 2. DAX Measures Dictionary

Create a dedicated DAX measure table `_Measures`.

### Financial & Sales Core Measures
```dax
-- 1. Total Net Revenue
Total Net Revenue = 
SUM(fact_order_items[net_revenue])

-- 2. Total Gross Profit
Total Gross Profit = 
SUM(fact_order_items[gross_profit])

-- 3. Gross Margin %
Gross Margin Pct = 
DIVIDE([Total Gross Profit], [Total Net Revenue], 0)

-- 4. Total Delivered Orders
Total Orders = 
CALCULATE(
    DISTINCTCOUNT(fact_orders[order_id]),
    fact_orders[order_status] = "delivered"
)

-- 5. Average Order Value (AOV)
Average Order Value = 
DIVIDE([Total Net Revenue], [Total Orders], 0)

-- 6. Total Active Customers
Total Active Customers = 
CALCULATE(
    DISTINCTCOUNT(fact_orders[customer_id]),
    fact_orders[order_status] = "delivered"
)
```

### Time Intelligence Measures
```dax
-- 7. Year-over-Year (YoY) Revenue Growth %
YoY Revenue Growth Pct = 
VAR PrevYearRevenue = 
    CALCULATE(
        [Total Net Revenue],
        SAMEPERIODLASTYEAR(dim_date[Date])
    )
RETURN
    DIVIDE([Total Net Revenue] - PrevYearRevenue, PrevYearRevenue, 0)

-- 8. Rolling 30-Day Net Revenue
Rolling 30D Revenue = 
CALCULATE(
    [Total Net Revenue],
    DATESINPERIOD(
        dim_date[Date],
        MAX(dim_date[Date]),
        -30,
        DAY
    )
)

-- 9. Month-over-Month (MoM) Growth
MoM Revenue Growth Pct = 
VAR PreviousMonthRevenue = 
    CALCULATE(
        [Total Net Revenue],
        DATEADD(dim_date[Date], -1, MONTH)
    )
RETURN
    DIVIDE([Total Net Revenue] - PreviousMonthRevenue, PreviousMonthRevenue, 0)
```

### Customer Retention & Marketing DAX
```dax
-- 10. Repeat Customer Rate %
Repeat Customer Rate Pct = 
VAR MultiOrderCustomers = 
    CALCULATE(
        COUNTROWS(
            FILTER(
                VALUES(fact_orders[customer_id]),
                CALCULATE(COUNT(fact_orders[order_id])) > 1
            )
        )
    )
RETURN
    DIVIDE(MultiOrderCustomers, [Total Active Customers], 0)

-- 11. Customer Acquisition Cost (CAC)
Total CAC = 
SUM(dim_marketing[total_spend])

-- 12. Return on Ad Spend (ROAS)
ROAS = 
DIVIDE([Total Net Revenue], [Total CAC], 0)
```

---

## 3. Dashboard Multi-Page Layout Design

### Page 1: Executive KPI Overview
- **Header KPI Cards**: Net Revenue ($), Total Orders, AOV ($), Gross Margin (%), Total Active Customers.
- **Main Visual 1 (Combo Chart)**: Monthly Net Revenue (Bar) vs YoY Revenue Growth % (Line).
- **Main Visual 2 (Donut Chart)**: Revenue Breakdown by Product Category.
- **Slicers (Top Ribbon)**: Date Range Picker, Acquisition Channel Filter, Region Multi-Select.

### Page 2: Customer Retention & RFM Analytics
- **Visual 1 (Heatmap Matrix)**: Monthly Cohort Retention Rates (Cohort Signup Month vs Month +N).
- **Visual 2 (Scatter Plot)**: Customer Recency vs Frequency (bubbled by Monetary Spend).
- **Visual 3 (Stacked Bar Chart)**: RFM Tier Distribution (Champions, Loyal, At Risk, Lost).

### Page 3: Marketing & A/B Experiment Performance
- **Visual 1 (Clustered Column Chart)**: Marketing Spend vs Conversion Rate by Campaign Channel.
- **Visual 2 (KPI Cards - A/B Test)**: Control vs Treatment Conversion Rate (+2.7% Lift), AOV Lift (+20.0%).
- **Visual 3 (Waterfall Chart)**: Incremental Net Revenue Lift breakdown.
