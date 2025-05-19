SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    SUM(COALESCE(s.confirmed_amount, 0)) / 100 AS total_deposits  -- converted from kobo to Naira
FROM 
    users_customuser u
JOIN 
    plans_plan p ON u.id = p.owner_id
LEFT JOIN 
    savings_savingsaccount s ON p.id = s.plan_id AND s.confirmed_amount IS NOT NULL
WHERE 
    p.status_id = 1  -- only funded plans
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) > 0
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) > 0
ORDER BY 
    total_deposits DESC;
