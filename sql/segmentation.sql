WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    op.payment_value
  FROM `aks-sql-analytics.olist.orders` o
  JOIN `aks-sql-analytics.olist.customers` c
    ON o.customer_id = c.customer_id
  JOIN `aks-sql-analytics.olist.order_payments` op
    ON o.order_id = op.order_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),

rfm_base AS (
  SELECT
    customer_unique_id,
    DATE_DIFF(
      (SELECT MAX(order_date) FROM customer_orders),
      MAX(order_date),
      DAY
    ) AS recency_days,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(payment_value) AS monetary
  FROM customer_orders
  GROUP BY customer_unique_id
),

rfm_scored AS (
  SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
  FROM rfm_base
)

SELECT
  customer_unique_id,
  recency_days,
  frequency,
  monetary,
  recency_score,
  frequency_score,
  monetary_score,
  (recency_score + frequency_score + monetary_score) AS rfm_total,
  CASE
    WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
    WHEN recency_score >= 4 AND frequency_score >= 3 THEN 'Loyal Customers'
    WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
    WHEN recency_score BETWEEN 2 AND 3 AND frequency_score >= 3 THEN 'At Risk'
    WHEN recency_score <= 2 AND frequency_score >= 4 THEN 'Cant Lose Them'
    WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
    ELSE 'Needs Attention'
  END AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;