SELECT 
	u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count,
    SUM(p.amount) AS total_deposits
FROM 
    adashi_staging.users_customuser u
JOIN 
    plans_plan p ON u.id = p.owner_id
LEFT JOIN 
    savings_savingsaccount s ON s.plan_id = p.id
WHERE 
    p.status_id = 1  -- Only funded plans
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) > 0
    AND COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) > 0
ORDER BY 
    total_deposits DESC;