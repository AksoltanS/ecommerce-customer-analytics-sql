-- =====================================================
-- 01_schema_exploration.sql
-- Purpose: Get familiar with table sizes and structure
-- before writing any analytical queries.
-- =====================================================

-- 1. Row counts across all tables
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM `aks-sql-analytics.olist.customers`
UNION ALL
SELECT 'orders', COUNT(*) FROM `aks-sql-analytics.olist.orders`
UNION ALL
SELECT 'order_items', COUNT(*) FROM `aks-sql-analytics.olist.order_items`
UNION ALL
SELECT 'order_payments', COUNT(*) FROM `aks-sql-analytics.olist.order_payments`
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM `aks-sql-analytics.olist.order_reviews`
UNION ALL
SELECT 'products', COUNT(*) FROM `aks-sql-analytics.olist.products`
UNION ALL
SELECT 'sellers', COUNT(*) FROM `aks-sql-analytics.olist.sellers`
UNION ALL
SELECT 'geolocation', COUNT(*) FROM `aks-sql-analytics.olist.geolocation`
UNION ALL
SELECT 'product_category_translation', COUNT(*) FROM `aks-sql-analytics.olist.product_category_translation`;

-- 2. Check for duplicate order_id in orders table (should be 0 duplicates)
SELECT order_id, COUNT(*) AS occurrences
FROM `aks-sql-analytics.olist.orders`
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 3. Check date range of orders
SELECT
  MIN(order_purchase_timestamp) AS earliest_order,
  MAX(order_purchase_timestamp) AS latest_order
FROM `aks-sql-analytics.olist.orders`;

-- 4. Check order status breakdown
SELECT order_status, COUNT(*) AS num_orders
FROM `aks-sql-analytics.olist.orders`
GROUP BY order_status
ORDER BY num_orders DESC;

-- 5. Check for nulls in key join columns
SELECT
  COUNTIF(customer_id IS NULL) AS null_customer_id,
  COUNTIF(order_id IS NULL) AS null_order_id
FROM `aks-sql-analytics.olist.orders`;
