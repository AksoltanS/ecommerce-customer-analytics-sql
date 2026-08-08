WITH seller_orders AS (
  SELECT
    oi.seller_id,
    oi.order_id,
    o.customer_id,
    DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_estimated_delivery_date),
      DAY
    ) AS delivery_delay_days
  FROM `aks-sql-analytics.olist.order_items` oi
  JOIN `aks-sql-analytics.olist.orders` o
    ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
),

seller_stats AS (
  SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(AVG(delivery_delay_days), 1) AS avg_delay_days
  FROM seller_orders
  GROUP BY seller_id
  HAVING COUNT(DISTINCT order_id) >= 20  -- sellers with enough volume to compare fairly
),

seller_groups AS (
  SELECT
    seller_id,
    num_orders,
    avg_delay_days,
    CASE
      WHEN avg_delay_days <= -10 THEN 'Fast shippers'
      WHEN avg_delay_days > 0 THEN 'Slow shippers'
      ELSE 'Average shippers'
    END AS shipping_group
  FROM seller_stats
),

seller_reviews AS (
  SELECT
    oi.seller_id,
    AVG(r.review_score) AS avg_review_score
  FROM `aks-sql-analytics.olist.order_items` oi
  JOIN `aks-sql-analytics.olist.order_reviews` r
    ON oi.order_id = r.order_id
  GROUP BY oi.seller_id
)

SELECT
  sg.shipping_group,
  COUNT(*) AS num_sellers,
  ROUND(AVG(sg.avg_delay_days), 1) AS avg_delay_days,
  ROUND(AVG(sr.avg_review_score), 2) AS avg_review_score
FROM seller_groups sg
JOIN seller_reviews sr
  ON sg.seller_id = sr.seller_id
GROUP BY sg.shipping_group
ORDER BY avg_review_score DESC;