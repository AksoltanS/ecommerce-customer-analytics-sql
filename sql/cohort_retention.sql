WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month
  FROM `aks-sql-analytics.olist.orders` o
  JOIN `aks-sql-analytics.olist.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),

first_purchase AS (
  SELECT
    customer_unique_id,
    MIN(order_month) AS cohort_month
  FROM customer_orders
  GROUP BY customer_unique_id
),

cohort_activity AS (
  SELECT
    fp.cohort_month,
    co.order_month,
    DATE_DIFF(co.order_month, fp.cohort_month, MONTH) AS month_number,
    co.customer_unique_id
  FROM customer_orders co
  JOIN first_purchase fp
    ON co.customer_unique_id = fp.customer_unique_id
)

SELECT
  cohort_month,
  month_number,
  COUNT(DISTINCT customer_unique_id) AS active_customers
FROM cohort_activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;