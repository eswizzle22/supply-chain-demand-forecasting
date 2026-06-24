-- =============================================
-- Data Quality Investigation Log
-- Purpose: Diagnose anomalies discovered in monthly trend analysis (Q3)
-- Author: Ella Sajor
-- Database: supply_chain (PostgreSQL)
-- Dataset: DataCo Supply Chain 2015–2018
-- =============================================

-- INVESTIGATION 1: Rows-per-order ratio collapse
-- Trigger: Q3 chart showed apparent ~70% revenue decline starting Oct 2017
SELECT 
    DATE_TRUNC('month', order_date) AS order_month,
    market,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(*) AS row_count,
    ROUND(COUNT(*)::numeric / COUNT(DISTINCT order_id), 2) AS rows_per_order
FROM orders
WHERE order_date >= '2017-08-01' AND order_date < '2018-02-01'
GROUP BY 1, 2
ORDER BY 1, 2;
-- Findings:
-- Shows a change in ratio from approximately 3 items per order (shown by rows) to exactly 1.0
-- This is shown over the time frame capturing the revenue decline from August 2017 - Jan 2018
-- Only 2 markets are recorded in this window - furhter investigation must be done.


-- INVESTIGATION 2: Market-level date range check
-- Trigger: Investigation 1 led to checking whether the issue was global or regional
SELECT 
    market,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(*) AS total_rows
FROM orders
GROUP BY market
ORDER BY first_order_date;
-- Findings: 
-- Each market's data spans over a range of months shown as following:
-- LATAM -> Jan 2015 - June 2017 (28 months)
-- Europe -> May 2015 - Nov 2017 (28 months)
-- Pacific Asia -> Oct 2015 - Jan 2018 (27 months)
-- USCA -> April 2016 - Jan 2017 (10 months)
-- Africa -> August 2016 - Jan 2017 (6 months)


-- INVESTIGATION 3: Per-market monthly investigation 
-- Trigger: Confirming whether each market show their own ratio issues, and find active data range
SELECT 
    market,
    DATE_TRUNC('month', order_date) AS order_month,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(*) AS row_count,
    ROUND(COUNT(*)::numeric / COUNT(DISTINCT order_id), 2) AS rows_per_order
FROM orders
GROUP BY market, DATE_TRUNC('month', order_date)
ORDER BY market, order_month;
-- Findings:
-- This dataset exhibits two compounding issues found from this investigation.
-- (1) Every market has large blocks of entirely missing months scattered throughout
--     its timeline (e.g., Europe missing Nov 2015-Jul 2016; LATAM missing Jun 2015-Dec
--     2016), not just a single clean start/end date.
-- (2) In the final 2-3 months before a market's data terminates, the items-per-order
--     ratio collapses from a stable ~3.0 to exactly 1.0 (confirmed independently in
--     both Europe [Oct-Nov 2017] and Pacific Asia [Nov 2017-Jan 2018]). This appears
--     to be a signature of how each market's data feed was extracted/terminated,
--     not a real change in customer purchasing behavior.
-- Given both issues, company-wide and even single-market monthly aggregates require
-- careful date-range scoping.


-- INVESTIGATION 4: Longest continuous run of months per market
-- Purpose: Determine if any market has a long enough unbroken stretch of consecutive
-- months to support reliable monthly forecasting, given confirmed gaps in every market
WITH monthly AS (
    SELECT 
        market,
        DATE_TRUNC('month', order_date) AS order_month
    FROM orders
    GROUP BY market, DATE_TRUNC('month', order_date)
),
numbered AS (
    SELECT 
        market,
        order_month,
        ROW_NUMBER() OVER (PARTITION BY market ORDER BY order_month) AS rn
    FROM monthly
),
grouped AS (
    SELECT 
        market,
        order_month,
        order_month - (rn * INTERVAL '1 month') AS run_group
    FROM numbered
),
run_lengths AS (
    SELECT 
        market,
        run_group,
        MIN(order_month) AS run_start,
        MAX(order_month) AS run_end,
        COUNT(*) AS consecutive_months
    FROM grouped
    GROUP BY market, run_group
)
SELECT 
    market,
    run_start,
    run_end,
    consecutive_months
FROM run_lengths
ORDER BY market, consecutive_months DESC;
-- Findings: 
-- The longest number of consecutive months for any single market was 10 (USCA).
-- This falls short of the 12-month minimum needed to capture even one full seasonal
-- cycle, and well short of the 24+ months generally recommended to reliably distinguish
-- real seasonality from noise. No market has sufficient continuous history to support
-- a standalone regional demand forecast. 


-- INVESTIGATION 5: Company-wide data cleanliness
-- Purpose: Confirm company-wide aggregate has no gaps in the proposed training window
SELECT 
    DATE_TRUNC('month', order_date) AS order_month,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(*) AS row_count,
    ROUND(COUNT(*)::numeric / COUNT(DISTINCT order_id), 2) AS rows_per_order
FROM orders
WHERE order_date >= '2015-01-01' AND order_date < '2017-10-01'
GROUP BY 1
ORDER BY 1;
-- Findings: 
-- All 33 months from Jan 2015-Sep 2017 are present with no gaps, and the items-per-order
-- ratio remains consistent at approximately 3.0 throughout. This confirms the company-wide
-- aggregate for this window is clean on both dimensions of data quality identified earlier
-- continuity and ratio stability.


-- =============================================
-- DECISION: Proceed with a company-wide demand forecasting model using the 33
-- consecutive clean months from Jan 2015-Sep 2017, where aggregate monthly totals
-- remain stable even though the underlying market mix contributing to that total 
-- may vary month to month due to confirmed per-market gaps. This window predates the
-- items-per-order ratio collapse identified in Investigation 1 and the market
-- drop-off pattern identified in Investigation 2/3. Per-market investment-opportunity
-- comparison was explored but is not supported by this dataset's regional data
-- completeness.
-- =============================================
