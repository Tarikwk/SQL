--1.
-- Use a window function to add columns showing:
-- The maximum population (max_pop) for each county.
-- The minimum population (min_pop) for each county.

SELECT year,
	   population, 
	   county,
	   MIN(population) OVER(
		   PARTITION BY county) AS min_population,
	   MAX(population) OVER(
		   PARTITION BY county) AS MAX_population
FROM population; 


SELECT *,
	MAX(population) OVER (PARTITION BY county) as max_pop, 
	MIN(population) OVER (PARTITION BY county) as min_pop 
FROM population; 


--2.
-- Rank counties from largest to smallest population for each year.

SELECT *,
	RANK () OVER(PARTITION BY year ORDER BY population DESC)
FROM population; 


--3. 
-- Use the unemployment table:
-- Calculate the rolling 12-month average unemployment rate using the unemployment table.
-- Include the current month and the preceding 11 months.
-- Hint: Reference two columns in the ORDER BY argument (county and period).

SELECT *, AVG (value) OVER (PARTITION BY county ORDER BY year, period ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS month_avg
FROM unemployment; 