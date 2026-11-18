# Google Sheets Executive KPI Report Specification

**Project**: End-to-End E-Commerce Sales, Customer & Marketing Analytics  
**Target Platform**: Google Sheets / Microsoft Excel  
**Workbook Architecture**: 4 Interlinked Tabs (`Summary_Dashboard`, `Data_Orders`, `Data_Marketing`, `Data_Customers`)

---

## 1. Sheet Architecture & Tab Structure

```
+-----------------------------------------------------------------------+
|  [Tab 1: Executive_Dashboard]  <-- Interactive KPI Scorecard & Visuals |
+-----------------------------------------------------------------------+
        ^                       ^                      ^
        | SUMIFS / QUERY        | XLOOKUP              | AVERAGEIFS
+--------------------+  +-------------------+  +------------------------+
|  [Tab 2: Orders]   |  | [Tab 3: Marketing]|  |  [Tab 4: Customers]    |
+--------------------+  +-------------------+  +------------------------+
```

---

## 2. Spreadsheet Formula Blueprints

### Executive KPI Scorecard Formulas (Summary_Dashboard Tab)

#### 1. Total Net Revenue
```excel
=SUM(Data_Orders!G2:G25001)
```

#### 2. Delivered Order Volume
```excel
=COUNTIFS(Data_Orders!C2:C25001, "delivered")
```

#### 3. Average Order Value (AOV)
```excel
=AVERAGEIFS(Data_Orders!G2:G25001, Data_Orders!C2:C25001, "delivered")
```

#### 4. Filtered Monthly Revenue by Region (Dynamic Dropdown in Cell B2)
```excel
=SUMIFS(Data_Orders!G2:G25001, Data_Orders!C2:C25001, "delivered", Data_Orders!E2:E25001, $B$2, Data_Orders!D2:D25001, ">="&$A5, Data_Orders!D2:D25001, "<="&EOMONTH($A5,0))
```

#### 5. Dynamic Customer Lookup via XLOOKUP (Search Customer ID in Cell F2)
```excel
=XLOOKUP($F$2, Data_Customers!A2:A10001, HSTACK(Data_Customers!B2:B10001, Data_Customers!D2:D10001, Data_Customers!E2:E10001), "Customer Not Found")
```

#### 6. Google Sheets QUERY Function for Top 5 Product Categories by Revenue
```excel
=QUERY(Data_Orders!A2:H25001, "SELECT H, SUM(G), AVG(G) WHERE C = 'delivered' GROUP BY H ORDER BY SUM(G) DESC LIMIT 5 LABEL H 'Category', SUM(G) 'Net Revenue', AVG(G) 'AOV'", 1)
```

#### 7. In-Cell Trendline Sparkline (Monthly Revenue Trajectory)
```excel
=SPARKLINE(B5:B16, {"charttype","line"; "linewidth",2; "color","#1f77b4"})
```

---

## 3. Conditional Formatting & Interactive Rules

1. **MoM Revenue Growth Indicator**:
   - **Rule**: If Cell `D5 > 0` -> Highlight Soft Green (`#E6F4EA`), Text Dark Green (`#137333`).
   - **Rule**: If Cell `D5 < 0` -> Highlight Soft Red (`#FCE8E6`), Text Dark Red (`#C5221F`).
2. **Gross Margin Health Indicator**:
   - **Rule**: If Margin % `>= 45%` -> Soft Green background.
   - **Rule**: If Margin % `< 30%` -> Soft Yellow warning background.
