-- 1. Winter Olympics Gold Medals
SELECT *
FROM winter_games; 

-- Write a CTE called top_gold_winter to find the top 5 gold-medal-winning countries for Winter Olympics.
-- Query the CTE to select countries and their medal counts where gold medals won are ≥ 5.
WITH top_gold_winter AS ( 
	SELECT countries.country, 
		SUM(gold) AS top5_gold
	FROM winter_games
	INNER JOIN countries
	ON countries.id = winter_games.country_id
	WHERE gold IS NOT NULL 
	GROUP BY countries.country
	ORDER BY top5_gold DESC
	LIMIT 5
)
SElECT country, top5_gold 
FROM top_gold_winter
WHERE top5_gold >= 5
ORDER BY top5_gold DESC
limit 5;	
	
-- 2. Tall Athletes

-- Write a CTE called tall_athletes to find athletes taller than the average height for athletes in the database.
-- Query the CTE to return only female athletes over age 30 who meet the criteria.

WITH tall_athletes AS (
	SELECT DISTINCT name, height 
	FROM athletes
	WHERE height > (SELECT AVG(height) FROM athletes)
	)
SELECT *
FROM tall_athletes 
INNER JOIN athletes 
USING (name)
WHERE gender = 'F'	
	AND age > 30; 



-- 3. Average Weight of Female Athletes

-- Write a CTE called tall_over30_female_athletes for the results of Exercise 2.
-- Query the CTE to find the average weight of these athletes.

With tall_over30_female_athletes AS
(WITH tall_athletes AS (
	 SELECT name, height 
	 FROM athletes
	 WHERE height > (SELECT AVG(height) FROM athletes))
 SELECT name, gender, age 
 FROM tall_athletes 
 INNER JOIN athletes 
 USING (name)
 WHERE gender = 'F'	
	 AND age > 30)
SELECT  ROUND(AVG(weight) * 2.2, 2) AS rounded_weight_lbs
FROM athletes
INNER JOIN tall_over30_female_athletes
USING (name);
--multiplying by 2.2 convered the metric weight (kg) to imperial (lbs)

SELECT *
FROM athletes; 


 