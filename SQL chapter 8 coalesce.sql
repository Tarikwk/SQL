-- Display Country name, 4-digit year, count of Nobel prize winners (where the count is ≥ 1), and country size:
-- Large: Population > 100 million
-- Medium: Population between 50 and 100 million (inclusive)
-- Small: Population < 50 million
-- Sort results so that the country and year with the largest number of Nobel prize winners appear at the top.

SELECT c.country,
	   DATE_PART ('YEAR',cs.year::DATE) AS year,
	   SUM (cs.nobel_prize_winners) AS nobel_winners,
	   CASE
	   		WHEN cs.pop_in_millions::NUMERIC > 100 THEN 'Large'
			WHEN cs.pop_in_millions::NUMERIC BETWEEN 50 AND 100 THEN 'Medium'
			WHEN cs.pop_in_millions::NUMERIC < 50 THEN 'SMALL'
 		END AS Population 
FROM country_stats AS cs
INNER JOIN countries AS c
ON c.id = cs.country_id
WHERE cs.nobel_prize_winners >= 1
GROUP BY c.country, cs.year, cs.pop_in_millions
ORDER BY nobel_winners DESC; 

SELECT countries.country,
	   DATE_PART ('YEAR',country_stats.year::DATE) AS year,
	   COALESCE (country_stats.gdp::VARCHAR, 'unknown') AS gdp_amount
FROM country_stats
INNER JOIN countries
ON countries.id = country_stats.country_id;

SELECT *
FROM countries
INNER Join country_stats
ON id = country_id; 
--1st 

SELECT country, year, nobel_prize_winners
FROM countries
INNER Join country_stats
ON id = country_id;
--2nd make sure it works 


--look for 4 digits on left side of year column. soo
SELECT country, LEFT(year,4) nobel_prize_winners
FROM countries
INNER Join country_stats
ON id = country_id;

--dont forget to alias 
SELECT country, LEFT(year,4) AS year, nobel_prize_winners
FROM countries
INNER Join country_stats
ON id = country_id;

SELECT country, LEFT(year,4) AS year, nobel_prize_winners
	CASE WHEN pop_in_millions > 100 THEN 'large' 
		 WHEN pop_in_millions  BETWEEN 50 AND 100 THEN 'medium'
		 WHEN pop_in_millions < 50 THEN 'small' END as pop_cat
FROM countries
INNER Join country_stats
ON id = country_id;

SELECT country, LEFT(year,4) AS year, nobel_prize_winners,
	CASE WHEN pop_in_millions::NUMERIC > 100 THEN 'large' 
		 WHEN pop_in_millions::NUMERIC  BETWEEN 50 AND 100 THEN 'medium'
		 WHEN pop_in_millions::NUMERIC < 50 THEN 'small' END as pop_cat
FROM countries
INNER Join country_stats
ON id = country_id;


SELECT country, LEFT(year,4) AS year, nobel_prize_winners,
	CASE WHEN pop_in_millions::NUMERIC > 100 THEN 'large' 
		 WHEN pop_in_millions::NUMERIC  BETWEEN 50 AND 100 THEN 'medium'
		 WHEN pop_in_millions::NUMERIC < 50 THEN 'small' END as pop_cat
FROM countries
INNER Join country_stats
ON id = country_id
WHERE nobel_prize_winners >=1;

SELECT country, LEFT(year,4) AS year, nobel_prize_winners,
	CASE WHEN pop_in_millions::NUMERIC > 100 THEN 'large' 
		 WHEN pop_in_millions::NUMERIC  BETWEEN 50 AND 100 THEN 'medium'
		 WHEN pop_in_millions::NUMERIC < 50 THEN 'small' END as pop_cat
FROM countries
INNER Join country_stats
ON id = country_id
WHERE nobel_prize_winners >=1
ORDER BY nobel_prize_winners DESC;


-- Create the output below that shows a row for each country and each year. Use COALESCE() to display unknown when the gdp is NULL.

SELECT country, LEFT (year, 4) AS year, COALESCE (gdp, 'unknown') AS gdp
FROM countries 
INNER JOIN country_stats 
ON id = country_id; 
--note the error message (gdp IS A double precision because of how big it is, so cast it as varcar or text)

SELECT country, LEFT (year, 4) AS year, COALESCE (gdp::TEXT, 'unknown') AS gdp
FROM countries 
INNER JOIN country_stats 
ON id = country_id; 

SELECT country, LEFT (year, 4) AS year, COALESCE (gdp::MONEY::TEXT, 'unknown') AS gdp
FROM countries 
INNER JOIN country_stats 
ON id = country_id; 
--WONT WORK because of money NOTE the casting error 


SELECT country, LEFT (year, 4) AS year, COALESCE (gdp::INTEGER::MONEY::TEXT, 'unknown') AS gdp
FROM countries 
INNER JOIN country_stats 
ON id = country_id; 
--try casting to integer 
--ERROR will say integer is out of range. because integer cant handle that size of a data type


SELECT country, LEFT (year, 4) AS year, COALESCE (gdp::NUMERIC::MONEY::TEXT, 'unknown') AS gdp
FROM countries 
INNER JOIN country_stats 
ON id = country_id; 
-- so can cast as numeric or integer and then cast to money and then text 
--almost anything can be cast to /from numeric 

SELECT TRIM(country), LEFT (year, 4) AS year, COALESCE (gdp::NUMERIC::MONEY::TEXT, 'unknown') AS gdp
FROM countries 
INNER JOIN country_stats 
ON id = country_id; 
--with white space before the 'country' column you can clean it up with TRIM






