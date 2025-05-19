WITH savings_last_tx AS (
    SELECT
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date,
        'Savings' AS type
    FROM savings_savingsaccount
    WHERE transaction_status = 'confirmed' AND transaction_date IS NOT NULL
    GROUP BY plan_id, owner_id
),

investments_last_tx AS (
    SELECT
        id AS plan_id,
        owner_id,
        last_charge_date AS last_transaction_date,
        'Investment' AS type
    FROM plans_plan
    WHERE is_deleted = 0
),

all_accounts AS (
    SELECT plan_id, owner_id, type, last_transaction_date FROM savings_last_tx
    UNION ALL
    SELECT plan_id, owner_id, type, last_transaction_date FROM investments_last_tx
)

SELECT
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATEDIFF(CURRENT_DATE, last_transaction_date) AS inactivity_days
FROM all_accounts
WHERE
    last_transaction_date IS NULL
    OR last_transaction_date < CURRENT_DATE - INTERVAL 365 DAY
ORDER BY inactivity_days DESC;