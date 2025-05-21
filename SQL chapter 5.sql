-- 1. Find Athletes from Summer or Winter Games
-- Write a query to list all athlete names who participated in the Summer or Winter Olympics. Ensure no duplicates appear in the final table using a set theory clause.

 (SELECT DISTINCT athletes.name, 'Summer' AS season
 FROM summer_games
 INNER JOIN athletes
 ON summer_games.athlete_id = athletes.id)
UNION 
 (SELECT DISTINCT athletes.name, 'Winter' AS season
 FROM winter_games
 INNER JOIN athletes
 ON winter_games.athlete_id = athletes.id);


-- 2. Find Countries Participating in Both Games
-- Write a query to retrieve country_id and country_name for countries in the Summer Olympics.
-- Add a JOIN to include the country’s 2016 population and exclude the country_id from the SELECT statement.
-- Repeat the process for the Winter Olympics.
-- Use a set theory clause to combine the results.

 (SELECT DISTINCT c.country, cs.pop_in_millions::NUMERIC, cs.year
 FROM summer_games AS sg
 INNER JOIN countries AS c 
 ON sg.country_id = c.id
 INNER JOIN country_stats AS cs
 ON sg.country_id = cs.country_id
 WHERE cs.year = '2016-01-01')
INTERSECT
(SELECT DISTINCT c.country, cs.pop_in_millions::NUMERIC, cs.year
 FROM winter_games AS wg
 INNER JOIN countries AS c
 ON wg.country_id = c.id
 INNER JOIN country_stats AS cs
 ON wg.country_id = cs.country_id
 WHERE cs.year = '2016-01-01');


-- 3. Identify Countries Exclusive to the Summer Olympics
-- Return the country_name and region for countries present in the countries table but not in the winter_games table.
-- (Hint: Use a set theory clause where the top query doesn’t involve a JOIN, but the bottom query does.)

(SELECT country, region
 FROM countries
EXCEPT 
 SELECT countries.country, countries.region
 FROM winter_games
 INNER JOIN countries
 ON winter_games.country_id = countries.id);

 (SELECT id, country, region
FROM countries)
EXCEPT
(SELECT country_id, countries.country, countries.region
FROM winter_games
LEFT JOIN countries
ON winter_games.country_id = countries.id);

--Brenna's


 