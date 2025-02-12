-- 1️⃣ Finds users who made 5+ transactions in 1 minute.
-- 2️⃣ Detects transactions where the same user paid in 2+ countries within 10 minutes.
-- 3️⃣ Ranks users by total fraud amount.
-- 4️⃣ Optimizes the query for speed using indexing, CTEs, and window functions.

WITH temp_temp AS (
    SELECT  
        user_id, 
        COUNT(*) OVER(
            PARTITION BY user_id 
            ORDER BY timestamp 
            RANGE BETWEEN INTERVAL '1 MINUTE' PRECEDING AND CURRENT ROW
        ) AS doing_transaction 
    FROM transactions
), 
country_check AS (
    SELECT  
        user_id, 
        COUNT(DISTINCT location) OVER(
            PARTITION BY user_id 
            ORDER BY timestamp 
            RANGE BETWEEN INTERVAL '10 MINUTES' PRECEDING AND CURRENT ROW
        ) AS country_detection
    FROM transactions
), 
fraud_sum AS (
    SELECT  
        user_id, 
        SUM(amount) AS total_fraud_sum
    FROM transactions
    WHERE is_fraud = 1  
    GROUP BY user_id
), 
ranked_fraud AS (
    SELECT 
        user_id, 
        total_fraud_sum, 
        ROW_NUMBER() OVER(ORDER BY total_fraud_sum DESC) AS fraud_rank
    FROM fraud_sum
)
SELECT * FROM ranked_fraud;

