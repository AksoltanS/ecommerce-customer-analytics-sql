WITH delivered_orders AS (
  SELECT
    o.order_id,
    DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_estimated_delivery_date),
      DAY
    ) AS delivery_delay_days
  FROM `aks-sql-analytics.olist.orders` o
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
),

orders_with_reviews AS (
  SELECT
    d.order_id,
    d.delivery_delay_days,
    r.review_score,
    CASE
      WHEN d.delivery_delay_days <= -15 THEN '1. Very early (15+ days)'
      WHEN d.delivery_delay_days BETWEEN -14 AND -1 THEN '2. Early (1-14 days)'
      WHEN d.delivery_delay_days = 0 THEN '3. On time'
      WHEN d.delivery_delay_days BETWEEN 1 AND 7 THEN '4. Late (1-7 days)'
      WHEN d.delivery_delay_days BETWEEN 8 AND 30 THEN '5. Very late (8-30 days)'
      ELSE '6. Extremely late (30+ days)'
    END AS delay_bucket
  FROM delivered_orders d
  JOIN `aks-sql-analytics.olist.order_reviews` r
    ON d.order_id = r.order_id
)

SELECT
  delay_bucket,
  COUNT(*) AS num_orders,
  ROUND(AVG(review_score), 2) AS avg_review_score,
  ROUND(AVG(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) * 100, 1) AS pct_low_reviews
FROM orders_with_reviews
GROUP BY delay_bucket
ORDER BY delay_bucket;