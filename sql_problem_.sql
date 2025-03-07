
'''
  Tasks:

    Write an SQL query to find the top 3 most sold products from a database (use sample data).
    Optimize a slow query (simulate large data using joins and indexes).
    Implement window functions to analyze customer purchase behavior.
  ''' 
  

CREATE INDEX idx_event ON app_usage (user_id, event_date);

WITH first_login AS (
    SELECT user_id, MIN(event_date) AS first_date
    FROM app_usage
    WHERE event_type = 'login'
    GROUP BY user_id
),
weekly_retention AS (
    SELECT 
        u.user_id, 
        TIMESTAMPDIFF(WEEK, f.first_date, u.event_date) AS week_num
    FROM app_usage u
    JOIN first_login f ON u.user_id = f.user_id
    WHERE u.event_date >= f.first_date
)
SELECT week_num, COUNT(DISTINCT user_id) AS retained_users
FROM weekly_retention
GROUP BY week_num
ORDER BY week_num;

WITH user_activity AS (
    SELECT user_id, 
           SUM(session_duration) AS total_session_time, 
           SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM app_usage
    GROUP BY user_id
),
ranked_users AS (
    SELECT user_id, total_session_time, purchase_count,
           NTILE(100) OVER (ORDER BY total_session_time DESC) AS session_percentile,
           NTILE(100) OVER (ORDER BY purchase_count DESC) AS purchase_percentile
    FROM user_activity
)
SELECT user_id, total_session_time, purchase_count
FROM ranked_users
WHERE session_percentile = 1 OR purchase_percentile = 1
ORDER BY total_session_time DESC, purchase_count DESC;

