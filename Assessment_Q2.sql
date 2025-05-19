SELECT
    CASE
        WHEN COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) >= 10 THEN 'High Frequency'
        WHEN COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    
    COUNT(DISTINCT owner_id) AS customer_count,
    
    ROUND(AVG(COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m'))) 
          OVER (PARTITION BY 
            CASE
                WHEN COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) >= 10 THEN 'High Frequency'
                WHEN COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) BETWEEN 3 AND 9 THEN 'Medium Frequency'
                ELSE 'Low Frequency'
            END
          ), 1) AS avg_transactions_per_month

FROM savings_savingsaccount
WHERE transaction_status = 'confirmed'
  AND transaction_date IS NOT NULL
GROUP BY owner_id
ORDER BY frequency_category;