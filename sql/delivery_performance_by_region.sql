WITH delivered_orders AS (
  SELECT
    o.order_id,
    c.customer_state,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date,
    DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_estimated_delivery_date),
      DAY
    ) AS delivery_delay_days
  FROM `aks-sql-analytics.olist.orders` o
  JOIN `aks-sql-analytics.olist.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
  customer_state,
  COUNT(*) AS num_orders,
  ROUND(AVG(delivery_delay_days), 1) AS avg_delay_days,
  ROUND(AVG(CASE WHEN delivery_delay_days > 0 THEN 1 ELSE 0 END) * 100, 1) AS pct_orders_late,
  MAX(delivery_delay_days) AS worst_delay_days
FROM delivered_orders
GROUP BY customer_state
HAVING COUNT(*) >= 30
ORDER BY avg_delay_days DESC;