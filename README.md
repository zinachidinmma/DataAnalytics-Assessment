# DataAnalytics-Assessment
# Question 1
# Scenario:
We want to find high-value customers who have:
At least one funded savings plan
At least one funded investment plan
And get their total deposits
Sorted by highest total deposits

To solve this scenarion I used the combination of the differenet queries.
The first section involving the SELECT query:  
SELECT 
	u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count,
    SUM(p.amount) AS total_deposits
FROM 
    adashi_staging.users_customuser u

# What this SELECT does:
u.id AS owner_id:
Gets the user's unique ID and renames it as owner_id.

CONCAT(u.first_name, ' ', u.last_name) AS name:
Joins the user's first and last name as a full name.

COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count:
Counts how many savings plans the user has (where plan_type_id = 1).

COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count:
Counts how many investment plans the user has (where plan_type_id = 2).

SUM(p.amount) AS total_deposits:
Adds up the amount across all funded plans (savings + investment).

FROM users_customuser u:

The second section of code involving joins:
JOIN 
    plans_plan p ON u.id = p.owner_id
LEFT JOIN 
    savings_savingsaccount s ON s.plan_id = p.id

# What these joins do
From the users_customuser table, it joins the plans_plan table to get all plans owned by the user connecting the owner id with the user id
The LEFT JOIN bring in matching rows from the savings_savingsaccount table if they exist, but don’t exclude the main row (from plans_plan) even if no match is found.

WHERE 
    p.status_id = 1

This query filters the data including only  plans that are funded

