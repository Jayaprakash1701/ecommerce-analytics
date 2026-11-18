# E-Commerce & Marketing KPI Dictionary

**Project**: End-to-End E-Commerce Sales, Customer & Marketing Analytics  
**Version**: 1.0  
**Target Audience**: Data Analysts, Business Stakeholders, Analytics Engineers  

---

## 1. Executive Financial & Sales KPIs

| KPI Name | Business Definition | Mathematical Formula | Target Benchmark | Business Action / Usage |
|---|---|---|---|---|
| **Gross Sales** | Total invoice value before discounts and returns. | $\sum (\text{Unit Price} \times \text{Quantity})$ | Growth > 15% YoY | Baseline volume indicator. |
| **Net Revenue** | Total revenue realized after discounts. | $\text{Gross Sales} - \text{Discounts}$ | Steady Growth | Top-line financial metric. |
| **Gross Profit** | Revenue remaining after COGS (Cost of Goods Sold). | $\text{Net Revenue} - \text{COGS}$ | Maximize Dollar Value | Margin health check. |
| **Gross Margin %** | Percentage of revenue retained as gross profit. | $\left(\frac{\text{Gross Profit}}{\text{Net Revenue}}\right) \times 100$ | $\ge 45\%$ | Pricing strategy & product mix efficiency. |
| **Average Order Value (AOV)** | Average dollar spend per transaction. | $\frac{\text{Net Revenue}}{\text{Total Orders}}$ | $\$85.00 - \$110.00$ | Cross-selling & bundling effectiveness. |
| **Order Volume** | Total count of fulfilled delivered orders. | $\text{COUNT(DISTINCT order\_id)}$ | Scaling MoM | Operational fulfillment throughput. |

---

## 2. Customer & Retention KPIs

| KPI Name | Business Definition | Mathematical Formula | Target Benchmark | Business Action / Usage |
|---|---|---|---|---|
| **Active Buyers** | Count of unique customers placing orders in period. | $\text{COUNT(DISTINCT customer\_id)}$ | Expanding | User base engagement. |
| **Repeat Purchase Rate %** | Share of customers placing $>1$ order. | $\left(\frac{\text{Customers with } >1 \text{ Order}}{\text{Total Active Customers}}\right) \times 100$ | $\ge 25\%$ | Loyalty program health. |
| **Customer Retention Rate (M1/M3)** | % of cohort active 1 or 3 months after first buy. | $\left(\frac{\text{Active Cohort Users in Month N}}{\text{Original Cohort Size}}\right) \times 100$ | M1 $\ge 20\%$, M3 $\ge 12\%$ | Product-market fit & onboarding strength. |
| **RFM Champions Share** | High recency, frequency, monetary tier % | $\left(\frac{\text{Champions Count}}{\text{Total Customers}}\right) \times 100$ | $\ge 15\%$ | VIP rewards targeting. |

---

## 3. Marketing & Campaign Performance KPIs

| KPI Name | Business Definition | Mathematical Formula | Target Benchmark | Business Action / Usage |
|---|---|---|---|---|
| **Click-Through Rate (CTR)** | Ad engagement efficiency. | $\left(\frac{\text{Clicks}}{\text{Impressions}}\right) \times 100$ | $\ge 3.5\%$ | Creative & headline quality. |
| **Conversion Rate %** | Traffic to paying customer ratio. | $\left(\frac{\text{Conversions}}{\text{Clicks}}\right) \times 100$ | $\ge 12.0\%$ | Landing page & UX conversion rate optimization. |
| **Cost Per Acquisition (CPA/CAC)** | Ad spend needed to acquire 1 conversion. | $\frac{\text{Total Spend}}{\text{Conversions}}$ | $<\$15.00$ | Paid media budgeting. |
| **Return on Ad Spend (ROAS)** | Gross revenue generated per ad dollar spent. | $\frac{\text{Attributed Revenue}}{\text{Ad Spend}}$ | $\ge 4.0\times$ | Channel spend re-allocation. |
