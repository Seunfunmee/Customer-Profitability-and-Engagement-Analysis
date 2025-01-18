CREATE DATABASE profits;

USE profits;

SELECT
	COUNT(*)
FROM demographics;

SELECT
	COUNT(*)
FROM values_info;

SELECT *
FROM demographics;

SELECT *
FROM values_info;

UPDATE demographics
SET birth_date = CASE
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE demographics
MODIFY COLUMN birth_date DATE;

UPDATE demographics
SET reg_date = CASE
	WHEN reg_date LIKE '%/%' THEN date_format(str_to_date(reg_date, '%m/%d/%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE demographics
MODIFY COLUMN reg_date DATE;

ALTER TABLE demographics
ADD COLUMN age INT;

UPDATE demographics
SET age = timestampdiff(YEAR, birth_date, CURDATE());

SELECT 
	min(age) youngest,
    max(age) oldest
FROM demographics;

-- Customer Demographic Analysis

-- Age distributions of customers?
SELECT 
  CASE 
		 WHEN age BETWEEN 31 AND 45 THEN '31-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
  END AS age_group, 
  COUNT(*) AS customer_count
FROM demographics
GROUP BY age_group 
ORDER BY age_group;

-- profit contribution by different age groups and genders?
SELECT 
  CASE 
		 WHEN age BETWEEN 31 AND 45 THEN '31-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
  END AS age_group, gender, SUM(val.total_profit) AS total_profit
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
GROUP BY age_group, gender
ORDER BY total_profit desc;

-- How does customer source impact customer profitability?
SELECT dem.customer_source, SUM(val.total_profit) AS total_profit
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
GROUP BY dem.customer_source
ORDER BY total_profit DESC;

-- count of customers without purchase?
SELECT COUNT(dem.customer_id) AS no_purchase_count
FROM demographics dem
LEFT JOIN values_info val ON dem.customer_id = val.customer_id
WHERE val.customer_id IS NULL;

-- number of customers without purchase by customer source?
SELECT dem.customer_source, COUNT(dem.customer_id) AS no_purchase_count
FROM demographics dem
LEFT JOIN values_info val ON dem.customer_id = val.customer_id
WHERE val.customer_id IS NULL
GROUP BY dem.customer_source
ORDER BY no_purchase_count desc;

-- Profitability and Engagement Metrics

-- What is the average profit per customer for first and subsequent orders?
SELECT AVG(first_order_profit) AS avg_first_order_profit,
       AVG(subsequent_order_profit) AS avg_subsequent_order_profit
FROM values_info;

-- What is the average profit for customers who made only one order versus those who made multiple orders?
SELECT CASE 
          WHEN subsequent_orders_count = 0 THEN 'Single Order'
          ELSE 'Multiple Orders'
       END AS order_type,
       AVG(total_profit) AS avg_profit
FROM values_info
GROUP BY order_type;

-- Which customers have the highest lifetime value based on total profit and visit frequency?
SELECT dem.customer_id, dem.age, dem.gender, val.total_profit, val.number_of_visits
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
ORDER BY val.total_profit DESC, val.number_of_visits DESC
LIMIT 10;

-- Promotional Effectiveness

-- no of customers that participated in the promo?
SELECT COUNT(*) AS total_promo_customers
FROM values_info
WHERE total_value_of_all_promotions > 0;

-- no of customers that that didn't participate in the promo?
SELECT COUNT(*) AS total_promo_customers
FROM values_info
WHERE total_value_of_all_promotions = 0;

-- What is the average profit and order count for customers who engaged with promotions versus those who didn’t?
SELECT CASE 
          WHEN val.total_value_of_all_promotions > 0 THEN 'Engaged in Promotions'
          ELSE 'No Promotions'
       END AS promotion_engagement,
       AVG(total_profit) AS avg_profit,
       AVG(subsequent_orders_count) AS avg_order_count
FROM values_info val
GROUP BY promotion_engagement;

-- Which customer source has the highest use of promotions, and what is the associated profitability?
SELECT dem.customer_source, 
       SUM(val.total_value_of_all_promotions) AS total_promo_value,
       SUM(val.total_profit) AS total_profit
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
GROUP BY dem.customer_source
ORDER BY total_promo_value DESC;

-- customer source without promotion?
SELECT dem.customer_source, 
	COUNT(dem.customer_id) AS total_customers_without_promo
FROM demographics AS dem
LEFT JOIN values_info AS val ON dem.customer_id = val.customer_id
WHERE (val.total_value_of_all_promotions IS NULL OR val.total_value_of_all_promotions = 0)
GROUP BY dem.customer_source;

-- Customer Behavior Analysis

-- How does the average number of visits vary by age and gender?
SELECT CASE 
		 WHEN age BETWEEN 31 AND 45 THEN '31-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
  END AS age_group, dem.gender, AVG(val.number_of_visits) AS avg_visits
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
GROUP BY age_group, dem.gender
ORDER BY avg_visits DESC;

-- What is the average time between the first and subsequent orders for customers?
SELECT dem.customer_id, AVG(DATEDIFF(NOW(), dem.reg_date)) AS avg_time_between_orders
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
WHERE val.subsequent_orders_count > 0
GROUP BY dem.customer_id;
    
    SELECT
		min(reg_date)
	FROM demographics;
    
    SELECT
		max(reg_date)
	FROM demographics;
    
  -- Month registration analysis?  
-- number of registeration per day?
SELECT 
    reg_date, 
    COUNT(customer_id) AS customer_count
FROM 
    demographics
GROUP BY 
    reg_date
ORDER BY 
    customer_count DESC;
    
-- How do customer engagement metrics (number of visits) correlate with customer profitability?
SELECT number_of_visits, AVG(total_profit) AS avg_profit
FROM values_info
GROUP BY number_of_visits
ORDER BY number_of_visits DESC;

-- Addressing Potential Areas for Growth
SELECT COUNT(DISTINCT address_city) AS total_unique_cities
FROM demographics;

-- Which cities has the highest profitability per customer?

SELECT dem.address_city, count(val.total_profit) AS total_profit
FROM demographics dem
JOIN values_info val ON dem.customer_id = val.customer_id
GROUP BY dem.address_city
ORDER BY count(val.total_profit) DESC

