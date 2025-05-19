SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_a_fund = 1 THEN 'Investment'
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        ELSE 'Other'
    END AS type,
    COALESCE(
        (SELECT MAX(s.transaction_date)
         FROM savings_savingsaccount s
         WHERE s.plan_id = p.id AND s.transaction_status = 'confirmed'),
        p.last_charge_date
    ) AS last_transaction_date,
    
    DATEDIFF(CURDATE(), COALESCE(
        (SELECT MAX(s.transaction_date)
         FROM savings_savingsaccount s
         WHERE s.plan_id = p.id AND s.transaction_status = 'confirmed'),
        p.last_charge_date
    )) AS inactivity_days
FROM plans_plan p
WHERE
    p.is_deleted = 0 AND
    (
        (SELECT MAX(s.transaction_date)
         FROM savings_savingsaccount s
         WHERE s.plan_id = p.id AND s.transaction_status = 'confirmed') IS NULL
        AND p.last_charge_date IS NULL
        OR DATEDIFF(CURDATE(), COALESCE(
            (SELECT MAX(s.transaction_date)
             FROM savings_savingsaccount s
             WHERE s.plan_id = p.id AND s.transaction_status = 'confirmed'),
            p.last_charge_date
        )) > 365
    )
ORDER BY inactivity_days DESC;