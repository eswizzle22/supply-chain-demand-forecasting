-- =============================================
-- Category Profitability Delay 
-- Purpose: Builds on Q4a Category Profitability which identified categories that drive
-- the most profit. This query adds delay rate to determine which high-profit categories 
-- are also high-risk. 
-- Author: Ella Sajor
-- Database: supply_chain (PostgreSQL)
-- Dataset: DataCo Supply Chain 2015–2018
-- =============================================

SELECT
    category_name,
    SUM(order_profit_per_order) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        100.0 * SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END)
        / COUNT(DISTINCT order_id),
        2
    ) AS late_rate_pct
FROM orders
GROUP BY category_name
ORDER BY total_profit DESC;