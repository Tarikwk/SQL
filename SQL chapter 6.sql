-- Find which county had the most months with unemployment rates above the state average:
-- Write a query to calculate the state average unemployment rate.
SELECT AVG(value)
FROM unemployment;

-- Use this query in the WHERE clause of an outer query to filter for months above the average.

SELECT period_name, value
FROM unemployment
WHERE value > (SELECT AVG(value)
					 FROM unemployment);
					 
-- Use Select to count the number of months each county was above the average. Which country had the most?

SELECT period_name AS month , value AS avg_value
FROM unemployment
WHERE value > (SELECT AVG(value) AS avg_value 
					 FROM unemployment);

SELECT county, COUNT(period) AS num_months
FROM unemployment
WHERE value > (SELECT AVG(value) AS avg_value 
					 FROM unemployment)
GROUP BY county;					 

-- Find the average number of jobs created for each county based on projects involving the largest capital investment by each company:

-- Write a query to find each company’s largest capital investment, returning the company name along with the relevant capital investment amount for each.

SELECT company, MAX(capital_investment) AS max_cap_investment 
FROM ecd
GROUP BY company; 

SELECT *
FROM (SELECT company, MAX(capital_investment) AS max_cap_investment 
	FROM ecd
	WHERE capital_investment IS NOT NULL
	GROUP BY company) AS max_sub
		INNER JOIN ecd
		ON max_sub.company = ecd.company
		AND max_sub.max_cap_investment = ecd.capital_investment; 


SELECT county, AVG(new_jobs)
FROM (SELECT company, MAX(capital_investment) AS max_cap_investment 
	FROM ecd
	WHERE capital_investment IS NOT NULL
	GROUP BY company) AS max_sub
		INNER JOIN ecd
		ON max_sub.company = ecd.company
		AND max_sub.max_cap_investment = ecd.capital_investment
GROUP BY county; 

-- Use this query in the FROM clause of an outer query, alias it, and join it with the original table.


SELECT county, AVG (new_jobs) AS avg_new_jobs
FROM (SELECT company, MAX(capital_investment) AS max_invest 
	  FROM ecd
	  WHERE capital_investment IS NOT NULL
	  GROUP BY company) AS max_cap_investment 
	  INNER JOIN ecd 
	  ON max_cap_investment.company = ecd.company
	  AND max_cap_investment.max_invest = ecd.capital_investment
GROUP BY county
ORDER BY avg_new_jobs DESC;

-- Use Select * in the outer query to make sure your join worked properly

-- Adjust the SELECT clause to calculate the average number of jobs created by county.					 