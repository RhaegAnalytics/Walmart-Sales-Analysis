/* Walmart Revenue and Sales Analysis */

-- Introduction
-- This portfolio project demonstrates the analysis of Walmart sales data to extract insights and trends. The goal is to evaluate different aspects of the business, including payment methods, branch performance, revenue changes, and customer preferences.

-- Data Exploration and Preprocessing
-- 1. Data Schema Creation
CREATE SCHEMA walmart;

-- 2. Viewing Data
SELECT * FROM walmart;

-- 3. Formatting Time Data
ALTER TABLE walmart ADD formatted_time TIME;
UPDATE walmart SET formatted_time = STR_TO_DATE(time, '%H:%i:%s');

-- Insights and Analysis
-- 1. Analyzing Payment Methods
SELECT payment_method, COUNT(*) AS 'Total' FROM walmart GROUP BY payment_method;

-- 2. Counting Branches
SELECT COUNT(DISTINCT(branch)) AS 'Total Branch' FROM walmart;

-- 3. Finding Maximum Quantity Sold
SELECT MAX(quantity) AS 'Maximum Quantity' FROM walmart;

-- 4. Payment Types with Transactions and Quantity Sold
SELECT DISTINCT(payment_method), COUNT(*) AS 'No of Transaction', SUM(quantity) AS 'Quantity Sold' 
FROM walmart 
GROUP BY payment_method 
ORDER BY COUNT(*) DESC;

-- 5. Highest-Rated Category per Branch
SELECT branch, category, ROUND(Avg_Rating) AS 'Avg_Rating' 
FROM (SELECT branch, category, AVG(rating) AS 'Avg_Rating', 
RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS 'Ranks' 
FROM walmart 
GROUP BY branch, category) AS Average_rating 
 WHERE Ranks = 1;

-- 6. Busiest Day of Each Branch
SELECT branch, day, No_of_Transactions FROM
 (SELECT branch, DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS 'Day',
 COUNT(*) AS 'No_of_Transactions', 
 RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS 'Ranked' 
 FROM walmart GROUP BY branch, day) AS Busiest_Day 
 WHERE ranked = 1;

-- 7. Preferred Payment Method by Branch
SELECT branch, payment_method FROM 
(SELECT branch, payment_method, COUNT(*) AS 'Total_Transactions',
 RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS 'Ranked' 
 FROM walmart GROUP BY branch, payment_method) AS Preferred_Payment_Type
 WHERE Ranked = 1;

-- 8. Total Profit by Category
SELECT category, ROUND(SUM(unit_price * quantity * profit_margin), 2) 
AS 'Profit' FROM walmart 
GROUP BY category 
ORDER BY Profit DESC;

-- 9. Revenue Decrease Analysis
WITH revenue_2022 AS 
(SELECT branch, SUM(Total) AS 'Revenue' FROM walmart
 WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 GROUP BY branch), 
 revenue_2023 AS 
 (SELECT branch, SUM(Total) AS 'Revenue' FROM walmart 
 WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 GROUP BY branch) 
 SELECT ly.branch AS Branch, ly.revenue AS Last_Year_Revenue, py.revenue AS Present_Year_Revenue, 
 ROUND((CAST(IFNULL(ly.revenue, 0) AS SIGNED) - CAST(IFNULL(py.revenue, 0) AS SIGNED)) 
 / NULLIF(CAST(IFNULL(ly.revenue, 0) AS SIGNED), 0) * 100, 2) AS Revenue_Decrease_Percentage 
 FROM revenue_2022 ly 
 JOIN revenue_2023 py ON ly.branch = py.branch 
 WHERE ly.revenue > py.revenue 
 ORDER BY Revenue_Decrease_Percentage DESC LIMIT 5;

-- Conclusion
-- This analysis provides insights into Walmart's business operations, revealing payment preferences, busiest shifts, most profitable categories, and branches with declining revenue. These insights help Walmart make data-driven decisions to optimize performance and increase profitability.
