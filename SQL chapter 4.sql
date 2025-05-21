-- How many rows are in the athletes table? How many distinct athlete ids?

SELECT COUNT(*)
FROM athletes;

--4216

SELECT COUNT(DISTINCT id)
FROM athletes; 

--4215

-- Which years are represented in the summer_games, winter_games, and country_stats tables?

SELECT DISTINCT sg.year, wg.year, cs.year
FROM summer_games AS sg
FULL JOIN winter_games AS wg
ON sg.year = wg.year
FULL JOIN country_stats AS cs
ON wg.year = cs.year::DATE;

select DISTINCT year
FROM country_stats;

select DISTINCT year
FROM winter_games;

select DISTINCT year
FROM summer_games;

SELECT DISTINCT TO_CHAR(year::DATE, 'YYYY') AS year
FROM (
    SELECT year::DATE FROM summer_games
    UNION ALL
    SELECT year::DATE FROM winter_games
    UNION ALL
    SELECT year::DATE FROM country_stats
) AS combined_years
ORDER BY year ASC;

SELECT DISTINCT
sg.year,
wg.year,
cs.year
FROM summer_games sg
FULL JOIN winter_games wg
ON sg.year = wg.year
FULL JOIN country_stats cs
ON cs.year :: DATE = sg.year

-- How many distinct countries are represented in the countries and country_stats table?

SELECT COUNT(DISTINCT c.id)
FROM countries AS c
LEFT JOIN country_stats AS cs
ON c.id = cs.country_id;

SELECT COUNT (DISTINCT country)  
FROM countries; 

SELECT COUNT (DISTINCT country_id)  
FROM country_stats; 
--203

-- How many distinct events are in the winter_games and summer_games table?

SELECT COUNT(DISTINCT wg.event)
FROM winter_games AS wg
LEFT JOIN summer_games AS sg
ON wg.event = sg.event;

--32

SELECT COUNT(DISTINCT event)
FROM summer_games; 

--95

-- Count the number of athletes who participated in the summer games for each country. Your output should have country name and number of athletes in their own columns. Did any country have no athletes?


SELECT c.country, COUNT(DISTINCT athlete_id) AS athlete_num
FROM summer_games AS sg
LEFT JOIN countries as c
ON sg.country_id = c.id
GROUP BY c.country
ORDER BY athlete_num;

--I used INNER JOIN, BUT Barry used LEFT JOIN, because if a country didnt have any athlestes they would still be represented in the table as null. the question wanted to know if it had NO athletes, and we could not check forsure if we did not use LEFT JOIN. 

SELECT *
FROM countries
LEFT JOIN summer_games 
ON countries.id = summer_games.country_id;


-- Write a query to list countries by total bronze medals, with the highest totals at the top and nulls at the bottom.
-- Adjust the query to only return the country with the most bronze medals

SELECT c.country, COUNT(sg.bronze) + COUNT(wg.bronze) AS total_bronze
FROM summer_games AS sg
INNER JOIN winter_games AS wg
ON sg.bronze = wg.bronze 
INNER JOIN countries as c
ON sg.country_id = c.id
GROUP BY c.country;
--mine 

SELECT *
FROM countries
LEFT JOIN summer_games
ON countries.id = summer_games.country_id;
--1st 

SELECT country, SUM(bronze) AS total_bronze
--now you have an aggregte funcion so you have to have a group by clause 
FROM countries
LEFT JOIN summer_games
ON countries.id = summer_games.country_id
GROUP BY country;
--2nd


SELECT country, SUM(bronze) AS total_bronze
FROM countries
LEFT JOIN summer_games
ON countries.id = summer_games.country_id
GROUP BY country
ORDER BY total_bronze DESC NULLS LAST
LIMIT 1; 

-- Calculate the average population in the country_stats table for countries in the winter_games. This will require 2 joins.
-- First query gives you country names and the average population
-- Second query returns only countries that participated in the winter_games

SELECT *
FROM winter_games
INNER JOIN countries
--with inner joins the order doesnt matter 
ON winter_games.country_id = countries.id 
INNER JOIN country_stats
ON countries.id = country_stats.country_id; 
--could also not write in inner (could just write in JOIN)
--1st 

SELECT country, AVG(pop_in_millions::NUMERIC) AS avg_pop
--aggregate function so group by clause is neccessary 
--varchar cast it as numeric 
FROM winter_games
INNER JOIN countries
ON winter_games.country_id = countries.id 
INNER JOIN country_stats
ON countries.id = country_stats.country_id
GROUP BY country
ORDER BY avg_pop DESC; 


-- Identify countries where the population decreased from 2000 to 2006.

--compare stuff in a single table to each other you want to do a self join (per datacamp join assignment)

SELECT *
FROM country_stats AS a 
JOIN country_stats AS b 
ON a.country_id = b.country_id 
JOIN countries 
ON a.country_id = countries.id; 


SELECT *
FROM country_stats AS a 
JOIN country_stats AS b 
USING (country_id)
JOIN countries 
ON a.country_id = countries.id; 
-- could also use USING beause its a self join 

SELECT country, a.year, a.pop_in_millions, b.year, b.pop_in_millions
FROM country_stats AS a 
JOIN country_stats AS b 
USING (country_id)
JOIN countries 
ON a.country_id = countries.id
WHERE a.year = '2000-01-01' AND b.year = '2006-01-01';

SELECT country, a.year, a.pop_in_millions, b.year, b.pop_in_millions
FROM country_stats AS a 
JOIN country_stats AS b 
USING (country_id)
JOIN countries 
ON a.country_id = countries.id
WHERE a.year = '2000-01-01' AND b.year = '2006-01-01'
	AND a.pop_in_millions > b.pop_in_millions; 

SELECT country, a.year, a.pop_in_millions, b.year, b.pop_in_millions
FROM country_stats AS a 
JOIN country_stats AS b 
USING (country_id)
JOIN countries 
ON a.country_id = countries.id
WHERE a.year = '2000-01-01' AND b.year = '2006-01-01'
	AND a.pop_in_millions::NUMERIC > b.pop_in_millions::NUMERIC; 

--had to cast pop_in_million beause of the alphanumeric discrepancy VARCHAR
--VARCHAR will compare digit by digit 
--FROMS, THEN JOINS, THEN WHERE, THEN THE SELECT

--ZACH'S OVER COMPLICATED SOUTION: 
SELECT c.country,
    CAST(cs2006.pop_in_millions AS NUMERIC) AS pop_2006,
    CAST(cs2000.pop_in_millions AS NUMERIC) AS pop_2000,
    (CAST(cs2006.pop_in_millions AS NUMERIC) - CAST(cs2000.pop_in_millions AS NUMERIC)) AS population_change
FROM countries c
JOIN country_stats cs2006 ON c.id = cs2006.country_id AND EXTRACT(YEAR FROM cs2006.year::DATE) = 2006
JOIN country_stats cs2000 ON c.id = cs2000.country_id AND EXTRACT(YEAR FROM cs2000.year::DATE) = 2000
WHERE cs2006.pop_in_millions IS NOT NULL 
    AND cs2000.pop_in_millions IS NOT NULL
    AND (CAST(cs2006.pop_in_millions AS NUMERIC) - CAST(cs2000.pop_in_millions AS NUMERIC)) < 0
	ORDER BY population_change ASC;