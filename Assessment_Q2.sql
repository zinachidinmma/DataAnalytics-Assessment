-- Step 1: Calculate average monthly transactions for each customer
SELECT
    -- Categorize based on average transactions per month
    CASE
        WHEN monthly_avg >= 10 THEN 'High Frequency'
        WHEN monthly_avg BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,

    -- Count how many customers fall into each category
    COUNT(customer_id) AS customer_count,

    -- Calculate average monthly transactions for each category
    ROUND(AVG(monthly_avg), 1) AS avg_transactions_per_month

FROM (
    -- Inner query: calculate avg transactions per month per customer
    SELECT
        sa.owner_id AS customer_id,

        -- Count all confirmed transactions for the user
        -- Divide by number of months the user has transacted in
        COUNT(*) * 1.0 / COUNT(DISTINCT DATE_FORMAT(sa.transaction_date, '%Y-%m')) AS monthly_avg

    FROM savings_savingsaccount sa
    JOIN users_customuser u 
        ON u.id = sa.owner_id

    -- Only include active, non-deleted users and confirmed transactions
    WHERE u.is_account_deleted = 0 
      AND u.is_account_disabled = 0
      AND sa.transaction_status = 'confirmed'
      AND sa.transaction_date IS NOT NULL

    GROUP BY sa.owner_id
) AS customer_summary

-- Group by frequency category (High, Medium, Low)
GROUP BY frequency_category

-- Sort categories in order: High, Medium, Low
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;