# Supply Chain Analytics & Demand Forecasting

Supply Chain Analytics is a SQL, Tableau, and Python (Prophet) project that analyzes the DataCo Supply Chain dataset to understand where demand, delivery performance, and profitability intersect, and to forecast future order volume so supply planning can stay ahead of demand instead of reacting to it.

Late deliveries are a common and costly problem in supply chain operations. Across this dataset's 65,752 orders, 54.83% arrived late, with some shipping modes failing over 95% of the time despite being marketed as premium options. When a business doesn't know what demand is coming, it can't plan capacity to meet it, and growth in orders quietly turns into lost revenue from delivery failures. This project analyzes where demand is concentrated, where current operations are already strained, where the financial stakes are highest, and builds a forecasting model accurate enough to support real supply planning decisions.

## Links

Live dashboards: (dashboards/demand_forecasting_dashboards.twbx)

## Screenshots

![Dashboard 1 — Demand & Revenue Overview](https://public.tableau.com/views/1-DemandRevenueOverview/Dashboard1-DemandRevenueOverview?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
![Dashboard 2 — Logistics & Delivery Performance](https://public.tableau.com/views/2-SupplyChainLogisticsDeliveryPerformance/Dashboard2-LogisticsDelivery?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) 
![Dashboard 3 — Business Performance & Profitability](https://public.tableau.com/views/3-BusinessPerformanceProfitability/Dashboard3-BusinessPerformanceProfitability?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
![Dashboard 4 — Demand Forecasting Model](https://public.tableau.com/views/4-DemandForecastingModel/Dashboard4-DemandForecasting?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

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
