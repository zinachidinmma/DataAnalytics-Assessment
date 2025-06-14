# DataAnalytics-Assessment
# Question 1
We want to find high-value customers who have:
- At least one funded savings plan
- At least one funded investment plan
- And get their total deposits
- Sorted by highest total deposits

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
We want to:
Find how often each customer transacts monthly (average).

Classify them into frequency categories:
- High Frequency: 10 or more transactions per month
- Medium Frequency: 3–9 transactions/month
- Low Frequency: 2 or fewer transactions/month

For each category, show:
- How many customers are in it
- The average number of transactions per customer per month

# For the CASE Block of Code:
COUNT(*): Total number of confirmed transactions.

COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')): Number of months with transactions.

COUNT(*) / COUNT(DISTINCT months): Gives the average transactions per month.

CASE assigns a category based on that number.

# Deriving the customer count and average transactions
COUNT(DISTINCT owner_id) AS customer_count
Counts how many unique users fall into each frequency category.

ROUND(AVG(...) OVER (PARTITION BY ...)) AS avg_transactions_per_month
This part gives the average number of monthly transactions for users in each category:

AVG(COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')))
OVER (PARTITION BY CASE ... END)
AVG(...) OVER (PARTITION BY ...): Groups users by their frequency category and calculates the average of their monthly averages.
ROUND(..., 1): Rounds the result to one decimal place.

FROM savings_savingsaccount
We’re pulling all the transaction data from the savings table.

WHERE transaction_status = 'confirmed' AND transaction_date IS NOT NULL
I only want:
Confirmed transactions
Transactions with a valid date

GROUP BY owner_id
We compute average monthly transactions per customer.

ORDER BY frequency_category
Sorts the results alphabetically by category. 

# The challenge I faced qith this question was not receiveing any rows

# Question 3
We want to:
- Identify inactive customer plans (both savings and investment) where:
- There has been no transaction at all, or
- The last transaction was more than 365 days ago.

SELECT 
    p.id AS plan_id,
    p.owner_id,
We're selecting from the plans_plan table.
p.id is the unique ID of the plan.
p.owner_id is the user who owns the plan.

# FOR the CASE Block of CODE
This part checks what type of plan it is:
If is_a_fund = 1, it's an Investment plan.
If is_regular_savings = 1, it's a Savings plan.
Otherwise, it's labeled as Other.

For the COALECSE Block of Code
This calculates the most recent transaction date:
First, it looks for the latest confirmed transaction in the savings_savingsaccount table.
If no savings transaction is found, it falls back to p.last_charge_date (used for investments).
COALESCE() picks the first non-null value.

For the DATEDIFF Block of code   
Calculates how many days have passed since the last transaction.

# The FROM Block of Code
FROM plans_plan p
WHERE
    p.is_deleted = 0 AND
We're working only with active (not deleted) plans.

-- Subquery opened here for AND condition
    (
        (SELECT MAX(s.transaction_date)
         FROM savings_savingsaccount s
         WHERE s.plan_id = p.id AND s.transaction_status = 'confirmed') IS NULL
        AND p.last_charge_date IS NULL
Case 1: No transactions at all
No savings transactions found (IS NULL)
No investment charge (last_charge_date IS NULL)

Note second case inserted here with OR Condition
        OR DATEDIFF(CURDATE(), COALESCE(...)) > 365
    )
Case 2: Last transaction is older than 365 days

# Final Block of Code
ORDER BY inactivity_days DESC;
Sorts results from the most inactive to the least.

# Question 4
We want to identify each customer’s estimated lifetime value using:
- How long they've been a customer
- Number of transactions
- Sum of confirmed transaction amounts

# For the SELECT Block of code
it selects the customer's unique ID from the users_customuser table.
# For the CONCAT part of code
Combines the customer’s first and last name for display.
# For the TIMESTAMPDIFF part of code
Calculates how many months the customer has been with the platform (from when they joined to today).

# COUNT Block of code
  COUNT(s.id) AS total_transactions,
Counts the number of confirmed savings transactions made by the customer.
This uses the LEFT JOIN (explained below).


    ROUND(
        (COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1)) 
        * 12 
        * (SUM(s.confirmed_amount) * 0.001), 
        2
    ) AS estimated_clv
Let’s break this formula into parts:

Part 1: COUNT(s.id) / tenure_months * 12
Calculates the annualized transaction rate.

Part 2: SUM(s.confirmed_amount) * 0.001
Adds up all the confirmed transaction amounts for the customer.
It's multiplied by 0.001 to convert kobo to naira (if amounts are stored in kobo).

Full Formula:
Combines both:
Annual transaction frequency × average transaction value
= Estimated Annual Value

The ROUND(..., 2) keeps it to 2 decimal places.

# LEFT JOIN block of code

LEFT JOIN savings_savingsaccount s 
    ON u.id = s.owner_id AND s.transaction_status = 'confirmed'
Joins each customer to their confirmed savings transactions, if any.

LEFT JOIN ensures users without transactions are still shown (with NULLs or 0s).

# GROUP BY block of code

GROUP BY u.id, u.first_name, u.last_name, u.date_joined
Groups the data by each customer, so aggregations (COUNT and SUM) work correctly.

# ORDER BY block of code
ORDER BY estimated_clv DESC;
Sorts the output by highest estimated CLV at the top.

