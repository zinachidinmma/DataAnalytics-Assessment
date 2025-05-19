# DataAnalytics-Assessment
# Question 1
# Scenario:
We want to find high-value customers who have:
At least one funded savings plan
At least one funded investment plan
And get their total deposits
Sorted by highest total deposits

To solve this scenario I used the combination of the differenet queries.
The first section involving the SELECT query:  
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    SUM(COALESCE(s.confirmed_amount, 0)) / 100 AS total_deposits
FROM 
    adashi_staging.users_customuser u

# What this SELECT does:
u.id AS owner_id:
Gets the user's unique ID and renames it as owner_id.

CONCAT(u.first_name, ' ', u.last_name) AS name:
Joins the user's first and last name as a full name.

COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
Counts the number of unique savings plans.
A savings plan is identified by is_regular_savings = 1.

COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
Counts the number of unique investment plans.
An investment plan is identified by is_a_fund = 1.

SUM(p.amount) AS total_deposits:
Adds up the amount across all funded plans (savings + investment).

SUM(COALESCE(s.confirmed_amount, 0)) / 100 AS total_deposits
Sums up all confirmed deposits (confirmed_amount) from the savings_savingsaccount table.
Uses COALESCE(..., 0) to handle null values.
Divides by 100 to convert from kobo to Naira.
Labels this result as total_deposits.

The second section of code involving joins:
FROM users_customuser u:
JOIN plans_plan p ON u.id = p.owner_id
LEFT JOIN 
savings_savingsaccount s ON p.id = s.plan_id AND s.confirmed_amount IS NOT NULL

# What these joins do
From the users_customuser table, it joins the plans_plan table to get all plans owned by the user connecting the owner id with the user id
The LEFT JOIN bring in Left join with the savings table, matching plans to their savings records.
Only includes rows where there is a confirmed deposit

WHERE 
    p.status_id = 1
This query filters the data including only  plans that are funded

The third section of code:
GROUP BY u.id, u.first_name, u.last_name
Groups results by each user to compute counts and total deposits per customer.

HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) > 0
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) > 0
Filters final results to include only customers who have:
At least 1 savings plan
At least 1 investment plan

The final section of code:
ORDER BY total_deposits DESC;
Sorts the results from highest to lowest total deposits.

# Question 2

