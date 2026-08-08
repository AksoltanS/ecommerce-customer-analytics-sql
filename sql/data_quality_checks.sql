
SELECT
  COUNT(DISTINCT customer_id) AS distinct_customer_id,
  COUNT(DISTINCT customer_unique_id) AS distinct_customer_unique_id
FROM `aks-sql-analytics.olist.customers`;

-- 2. Check referential integrity: every order should have a matching customer
SELECT COUNT(*) AS orphaned_orders
FROM `aks-sql-analytics.olist.orders` o
LEFT JOIN `aks-sql-analytics.olist.customers` c
  ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 3. Check every order_item has a matching order
SELECT COUNT(*) AS orphaned_order_items
FROM `aks-sql-analytics.olist.order_items` oi
LEFT JOIN `aks-sql-analytics.olist.orders` o
  ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 4. Check for null purchase timestamps 
SELECT COUNT(*) AS null_purchase_dates
FROM `aks-sql-analytics.olist.orders`
WHERE order_purchase_timestamp IS NULL;

-- 5. Check how many customers appear more than once
SELECT
  customer_unique_id,
  COUNT(DISTINCT customer_id) AS num_orders
FROM `aks-sql-analytics.olist.customers`
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1
ORDER BY num_orders DESC
LIMIT 20;