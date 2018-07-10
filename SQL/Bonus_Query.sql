WITH months AS 
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
 ),
 cross_join AS (
   SELECT *
   FROM subscriptions
   CROSS JOIN months
),
status As (
   SELECT 
    id,
    first_day AS month,
    segment,
    CASE WHEN  
        subscription_start < first_day
        AND (subscription_end > first_day
            OR subscription_end IS NULL)
        THEN 1
        ELSE 0 
    END AS is_active,
    CASE WHEN subscription_end 
        BETWEEN first_day AND last_day
        THEN 1
        ELSE 0 
    END AS is_canceled
    FROM cross_join
    ),
status_aggregate AS (
  SELECT month, 
       segment,
       SUM(is_active) AS sum_active,
       SUM(is_canceled) AS sum_canceled
       FROM status
GROUP BY 1, 2)
SELECT month, 
  segment,
  1.0 * sum_canceled/sum_active AS churn_rate
FROM status_aggregate;
