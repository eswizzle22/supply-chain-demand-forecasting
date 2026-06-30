# Supply Chain Analytics & Demand Forecasting

Supply Chain Analytics is a SQL, Tableau, and Python (Prophet) project that analyzes the DataCo Supply Chain dataset to understand where demand, delivery performance, and profitability intersect, and to forecast future order volume so supply planning can stay ahead of demand instead of reacting to it.

Late deliveries are a common and costly problem in supply chain operations. Across this dataset's 65,752 orders, 54.83% arrived late, with some shipping modes failing over 95% of the time despite being marketed as premium options. When a business doesn't know what demand is coming, it can't plan capacity to meet it, and growth in orders quietly turns into lost revenue from delivery failures. This project analyzes where demand is concentrated, where current operations are already strained, where the financial stakes are highest, and builds a forecasting model accurate enough to support real supply planning decisions.

## Links

Live dashboards: [`dashboards/demand_forecasting_workbook.twbx`](dashboards/demand_forecasting_dashboards.twbx)

## Screenshots
<img width="2398" height="1598" alt="Dashboard 1 - Demand   Revenue Overview" src="https://github.com/user-attachments/assets/d25f78f7-f478-44cf-9960-d1aae7001202" />

<img width="2398" height="1598" alt="Dashboard 2 - Logistics   Delivery" src="https://github.com/user-attachments/assets/201615dc-904c-44c8-b1a3-d4eb5a566492" />

<img width="2398" height="1598" alt="Dashboard 3 - Business Performance   Profitability" src="https://github.com/user-attachments/assets/05faa446-4006-4768-8434-bff4217e3e84" />

<img width="2398" height="1598" alt="Dashboard 4 - Demand Forecasting" src="https://github.com/user-attachments/assets/1b6d40a7-5cec-4a31-ac70-10f8a80f7a0b" />



## Features

* Four interactive Tableau dashboards covering demand, logistics, profitability, and forecasting
* SQL analysis using CTEs and window functions across 180,519 orders
* A documented, query-by-query investigation into a real data quality issue found in the source dataset
* A validated, gap-free 33-month training window identified and confirmed through SQL before modeling
* A Prophet time-series demand forecasting model with a true 6-month holdout for validation
* Category and market-level breakdowns connecting demand, delivery risk, and profit at risk

## Tech Stack

* PostgreSQL
* Tableau Public
* Python (Prophet, pandas)
* SQL (CTEs, window functions)

## Key Findings

| Metric | Value |
|---|---|
| Total revenue analyzed | $36,784,734 |
| Total orders | 65,752 |
| Average orders/month (clean window) | 1,737 |
| Overall late delivery rate | 54.83% |
| First Class shipping late rate | 95.3% (despite being the premium tier) |
| Profit at risk (top 20 delayed products) | $23,248 |
| Revenue share, top category (Fishing) | 18.84% |
| Forecast model accuracy (MAPE) | 1.09% |
| Forecast training window | Jan 2015–Sep 2017 (33 validated clean months) |

## Outcome

This project was built as a self-directed portfolio piece to demonstrate end-to-end analytics work, from raw SQL querying through dashboard design to applied machine learning. The final forecasting model reached a 1.09% MAPE, accurate enough to support real supply planning decisions. The four dashboards tie together a complete story: what demand looks like, why forecasting matters operationally, and where the business stands to gain the most by acting on it.

## Key Learnings

Midway through this project, the monthly revenue trend showed an apparent 70% decline that didn't match the rest of the data. Rather than excluding it or explaining it away, I traced it back through five separate SQL investigations and found that each of the dataset's 5 markets had different, non-overlapping active date ranges with scattered gaps throughout, and that an items-per-order logging change occurred near the end of each market's reporting window. This meant my original plan to forecast demand region by region wasn't supportable by the data, and I had to pivot to a single company-wide model scoped to a validated clean window instead. This taught me that correct-looking numbers aren't always trustworthy numbers, and that knowing when to scope a model more carefully is just as important as knowing how to build one in the first place.

Full investigation, query by query: [`sql/data_quality_investigation.sql`](sql/data_quality_investigation.sql)
