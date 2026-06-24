-- =============================================
-- Supply Chain Analysis 
-- Purpose: Understand the business through 5 main queries
-- Author: Ella Sajor
-- Database: supply_chain (PostgreSQL)
-- Dataset: DataCo Supply Chain 2015–2018
-- =============================================


-- q1. Late Delivery Rate by Market & Shipping Mode
-- Business question: Which regions and shipping modes have the worst on-time performance?
-- Excludes Payment Review and Suspected Fraud orders as they are unfufilled orders
SELECT 
	market, 
	shipping_mode, 
	COUNT(*) AS total_orders, 
	SUM(CASE WHEN delivery_status='Late delivery' THEN 1 ELSE 0 END) AS late_orders,
	ROUND(100.0* SUM(CASE WHEN delivery_status= 'Late delivery' THEN 1 ELSE 0 END)/COUNT(*),2) AS late_rate_pct
FROM orders
WHERE order_status NOT IN ('Payment Review', 'Suspected Fraud')
GROUP BY market, shipping_mode 
ORDER BY late_rate_pct DESC;

-- q2. Shipping Delay Ranked by Product's Average Delay
-- Business question: Which products have the worst average delays and how much profit is at risk?
-- RANK() is a window function that assigns a ranked number to all grouped rows over average delays in descending order
-- Note: The top 20 largest product delays span from 1.94 to 1.71 days risking $23247.11 in profit from these products
WITH delay_calc AS (
	SELECT
		product_name,
		category_name,
		(days_shipping_real - days_shipping_scheduled) AS delay_days, 
		order_profit_per_order
	FROM orders
	WHERE delivery_status = 'Late delivery'
), 
ranked AS(
	SELECT 
		product_name,
		category_name, 
		ROUND(AVG(delay_days), 2) AS avg_delay_days, 
		ROUND(SUM(order_profit_per_order), 2) AS profit_at_risk, 
		RANK() OVER (ORDER BY AVG(delay_days) DESC) AS delay_rank 
	FROM delay_calc 
	GROUP BY product_name, category_name
)
SELECT * 
FROM ranked 
WHERE delay_rank <=20 
ORDER BY delay_rank;
	

-- q3. Revenue & Profit Trends by Month, Market, and Customer Segment
-- Business question: What does the monthly performance look like over time for each market and customer segment?
-- DATE_TRUNC reduces each order_date to the first of each month to allow for grouping by month
-- DATA QUALITY NOTE: Sustained decline in order volume and revenue starting on Oct 2, 2017 at 12:25 PM due to a structural change in order data logging
-- See data_quality_investigation.sql for furhter investigation!
	DATE_TRUNC('month', order_date) AS order_month, 
	market,
	customer_segment,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(sales) AS total_revenue,
	SUM(order_profit_per_order) AS total_profit,
	ROUND(AVG(order_item_profit_ratio)*100, 2) AS avg_margin_pct,
	SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS late_deliveries
FROM orders
GROUP BY 1, 2, 3
ORDER BY 1, 2;

-- q4. Categorical Product Analysis
-- a.) Product Category Profitability Ranking and Share of Revenue
-- Business question: Which product categories are the most and least profitable?
-- SUM(SUM(sales)) OVER() is a window function that calculates the grand total of sales by summing sales across all departments & categories
-- revenue_share_pct shows each category's revenue as a portion of total company revenue
-- Note: The Fishing category has the greatest share of total revenue accounting for 18.84%
SELECT
	department_name,
	category_name, 
	COUNT(*) AS order_count,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(order_profit_per_order),2) AS total_profit,
	ROUND(AVG(order_item_profit_ratio)*100, 2) AS avg_margin_pct, 
	ROUND(SUM(sales)/SUM(SUM(sales)) OVER() *100, 2) AS revenue_share_pct 
FROM orders
GROUP BY department_name, category_name
ORDER BY total_profit DESC;
-- b.) Product Category Order Volume Ranking
-- Business question: Which product categories drive the most order demand?
-- Identify which categories contribute most to overall order volume, complementing 4.a) profitability ranking
SELECT
	department_name,
	category_name, 
	COUNT(*) AS order_count,
	ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER() * 100, 2) AS order_share_pct
FROM orders
GROUP BY department_name, category_name
ORDER BY order_count DESC;


-- q5. Shipping Mode Delays and Profit Analysis
-- Business Question: Which shipping modes offer the best balance of speed, reliability, and profit?
-- avg_delay is the actual days subtracted from the scheduled amount of days for shipping
-- Note: First Class shipping has a 95.3% late rate despite being the most premium shipping option
SELECT
	shipping_mode,
	COUNT(*) AS orders,
	ROUND(AVG(days_shipping_real), 2) AS avg_actual_days,
	ROUND(AVG(days_shipping_scheduled), 2) AS avg_scheduled_days,
	ROUND(AVG(days_shipping_real - days_shipping_scheduled), 2) AS avg_delay,
	ROUND(AVG(order_profit_per_order), 2) AS avg_profit_per_order, 
	ROUND(100.0 * SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END)/COUNT(*), 1) AS late_rate_pct
FROM orders
GROUP BY shipping_mode
ORDER BY avg_actual_days;