-- 1) Write a query where the output is the top 5 countries in terms of total gold 
-- medals for the summer Olympics. The output should have 5 row and 2 
-- columns (country name and total gold medals)



SELECT c.country, SUM(sg.gold)::NUMERIC AS gold
FROM summer_games AS sg
INNER JOIN countries AS c
ON sg.country_id = c.id
WHERE sg.gold IS NOT NULL
GROUP BY c.country, sg.gold
ORDER BY sg.gold >= 1 DESC


-- 2) Write a query where the output is the year and the average population in 
-- millions using the country stats table.  Your results should have 17 rows and 
-- 2 columns (year and avg pop_in_million)



SELECT LEFT (year,4) AS year, AVG(pop_in_millions::NUMERIC) AS avg_pop
FROM country_stats
GROUP BY year 
ORDER BY year  

select *
FROM country_stats






-- 3) Using the athletes table write a query that returns the minimum, average (as
-- a whole number), and maximum heights based on gender.   Only include 
-- men older than 25 and women younger than 25.  Your results should have 2 
-- rows (M and F) and 4 columns (Gender, Min_height, avg_height, 
-- max_height

SELECT *
FROM athletes

SELECT
		MIN(height), 
		AVG(height),
		MAX(height)
FROM athletes
WHERE (gender = 'M' AND age > 25) OR (gender = 'F' AND age < 25) 
GROUP BY height, gender 



-- Find the count of men or women competing in either the summer or winter 
-- games by country.

WITH malebycountry AS 
(
SELECT COUNT(athletes.id)::INT AS athletes , country_id
FROM athletes
INNER JOIN summer_games 
ON athletes.id = summer_games.athlete_id
WHERE athletes.gender = 'M'
GROUP BY country_id, athletes.id
)
SELECT countries.country, SUM(malebycountry.athletes) AS athletes_per_country
FROM countries
INNER JOIN malebycountry 
ON country_id = countries.id
GROUP BY countries.country, malebycountry.athletes
ORDER BY athletes_per_country desc



-- 2) Which country has the most winter Olympics athletes over age 30?

WITH malebycountry AS 
(
SELECT COUNT(athletes.id)::INT AS athletes , country_id
FROM athletes
INNER JOIN winter_games 
ON athletes.id = winter_games.athlete_id
WHERE athletes.age > 30
GROUP BY country_id, athletes.id
)
SELECT countries.country, SUM(malebycountry.athletes) AS athletes_per_country
FROM countries
INNER JOIN malebycountry 
ON country_id = countries.id
GROUP BY countries.country, malebycountry.athletes
ORDER BY athletes_per_country desc

-- 3) What the is min, max, and average GDP in millions for countries who have at
-- least 1 summer Olympics Gold Medal and 1 Nobel Prize?

WITH atleastonebigwin AS 
(
SELECT DISTINCT country_id, summer_games.gold, country_stats.nobel_prize_winners
FROM summer_games
INNER JOIN country_stats USING (country_id)
WHERE (summer_games.gold IS NOT NULL AND summer_games.gold >= 1) AND (country_stats.nobel_prize_winners >= 1)
),
namethatb AS 
(
SELECT atleastonebigwin.country_id, MIN(country_stats.gdp), MAX(country_stats.gdp), AVG(country_stats.gdp)
FROM country_stats
INNER JOIN atleastonebigwin USING (country_id) 
GROUP BY atleastonebigwin.country_id
)
SELECT countries.country, namethatb.min, namethatb.max, namethatb.avg
FROM countries
INNER JOIN namethatb 
ON countries.id = namethatb.country_id



select *
FROM countries





