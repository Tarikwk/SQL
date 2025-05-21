--1. How many rows are in the data_analyst_jobs table?

SELECT COUNT(*)
FROM data_analyst_jobs;

--1793

--2. Write a query to look at just the first 10 rows. What company is associated with the job posting on the 10th row?


SELECT *
FROM data_analyst_jobs
LIMIT 10;

--ExxonMobile

--3. How many postings are in Tennessee? How many are there in either Tennessee or Kentucky?

SELECT COUNT(*)
FROM data_analyst_jobs
WHERE location = 'TN';

select count (*) as TN_jobs
from data_analyst_jobs
where location = 'TN';

select count (*) as tn_ky_jobs
from data_analyst_jobs
where location = 'TN'
	or location = 'KY';
	
--27

--4. How many postings in Tennessee have a star rating above 4?

SELECT COUNT(location)
FROM data_analyst_jobs
WHERE location LIKE 'TN'
	AND star_rating > 4;
--3

SELECT
	COUNT(CASE WHEN location = 'TN' THEN 'Tennessee' END) AS tn_job_count,
	COUNT(CASE WHEN location = 'KY' THEN 'Kentucky' END) AS ky_job_count
FROM data_analyst_jobs;

--commands written by Juan Doza 

--5. How many postings in the dataset have a review count between 500 and 1000?

SELECT COUNT(review_count)
FROM data_analyst_jobs
WHERE review_count BETWEEN 500 and 1000;

--151

SELECT COUNT (title) AS reviews_between_500_1000
FROM data_analyst_jobs
WHERE review_count > 500
AND review_count < 1000;

--Zach did this and got 150 vs our 151
--gives you 150 because > and < are inclusive 
--if you used >= and <= then you'd get 151

--6. Show the average star rating for companies in each state. The output should show the state as state and the average rating for the state as avg_rating. Which state shows the highest average rating?

SELECT location, AVG(star_rating) AS avg_rating
FROM data_analyst_jobs
WHERE location IS NOT NULL AND star_rating IS NOT NULL
GROUP BY location
ORDER BY avg_rating DESC;

--note that if you put where after group it wont work because of order of operation. 

--NE

--7. Select unique job titles from the data_analyst_jobs table. How many are there?

SELECT COUNT (DISTINCT title)
FROM data_analyst_jobs;

--881

-- 8. How many unique job titles are there for California companies?

SELECT  COUNT (DISTINCT title) AS distinct_job_count
FROM data_analyst_jobs
WHERE location = 'CA';

--230

-- 9. Find the name of each company and its average star rating for all companies that have more than 5000 reviews across all locations. How many companies are there with more that 5000 reviews across all locations?

SELECT COUNT(company), AVG(star_rating) AS avg_star_rating
FROM data_analyst_jobs
WHERE review_count > 5000 AND company IS NOT NULL
GROUP BY company
ORDER BY avg_star_rating DESC;


--mine wrong or open to interpretation 

SELECT company, AVG(star_rating) AS avg_rating
FROM data_analyst_jobs
WHERE company IS NOT NULL 
GROUP BY company
HAVING SUM(review_count) > 5000
ORDER BY avg_rating DESC;

--CORRECT takes all like company's and groups them together. 

-- 10. Add the code to order the query in #9 from highest to lowest average star rating. Which company with more than 5000 reviews across all locations in the dataset has the highest star rating? What is that rating?

--Google (see #9)

-- 11. Find all the job titles that contain the word ‘Analyst’. How many different job titles are there?

SELECT COUNT (DISTINCT title) AS analyst_count
FROM data_analyst_jobs
WHERE title ILIKE '%analyst%';

--774 (WITH DISTINCT TITLE)

SELECT COUNT (title) AS analyst_count
FROM data_analyst_jobs
WHERE title ILIKE '%analyst%';

--1669 (INCLUDING ALL TITLES)

--12. How many different job titles do not contain either the word ‘Analyst’ or the word ‘Analytics’? What word do these positions have in common?

SELECT DISTINCT title AS not_analyst_count
FROM data_analyst_jobs
WHERE title NOT ILIKE '%analyst%' 
AND title NOT ILIKE '%analytics%';		

--"PM/BA - Banking IT Risk / Ops Risk - Tableau - Up to $650/da..."
-- "Tableau Developer, Data Products"
-- "Data Visualization Specialist - Consultant (Tableau or Power..."
-- "Data Visualization Specialist - Consultant (Tableau or Alter..."

--could also use upper or lower to make everything the same and then draw your data 

--Tableau


--BONUS: You want to understand which jobs requiring SQL are hard to fill. Find the number of jobs by industry (domain) that require SQL and have been posted longer than 3 weeks.

-- Disregard any postings where the domain is NULL.
-- Order your results so that the domain with the greatest number of hard to fill jobs is at the top.
-- Which three industries are in the top 4 on this list? How many jobs have been listed for more than 3 weeks for each of the top 4?


SELECT DOMAIN, COUNT(skill) as sql_skill
FROM data_analyst_jobs
WHERE skill ILIKE '%SQL%'
AND domain IS NOT NULL 
AND days_since_posting > 21 
GROUP BY domain
ORDER BY sql_skill DESC
LIMIT 4;

-- could use (*) or (skill)

SELECT domain, COUNT(*) as sql_jobs
FROM data_analyst_jobs
WHERE skill ILIKE '%sql%'
AND days_since_posting> 21
AND DOMAIN IS NOT NULL
GROUP BY domain
ORDER BY sql_jobs DESC
LIMIT 4;

-- "Internet and Software"	62
-- "Banks and Financial Services"	61
-- "Consulting and Business Services"	57
-- "Health Care"	52
