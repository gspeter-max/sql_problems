WITH temp_temp AS ( 
    SELECT 
        customer_id, 
        SUM(amount) AS total_spending 
    FROM customer_transaction
    WHERE transaction_date >= DATEADD(MONTH, -6, GETDATE()) 
    GROUP BY customer_id 
), 
ranking_table AS (
    SELECT 
        customer_id, 
        total_spending, 
        DENSE_RANK() OVER(ORDER BY total_spending DESC) AS ranks
    FROM temp_temp 
)
SELECT * 
FROM ranking_table 
WHERE ranks <= 5;
