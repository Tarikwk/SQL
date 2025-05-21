--1.How many counties are represented? How many companies?

SELECT COUNT(DISTINCT county) AS county_count, COUNT(DISTINCT company) AS company_count
FROM ecd;

--88	764    name them if you do something like this for clarification using AS 

SELECT COUNT (DISTINCT company)
FROM ecd;
-- 764

--2.How many companies did not get ANY Economic Development grants (ed) for any of their projects? (Hint, you will probably need a couple of steps to figure this one out)

SELECT COUNT (DISTINCT company) AS companies_without_ed
FROM ecd
WHERE ed IS NULL;

--608  good practice to name the column when you do something like it  

--3. What is the total capital_investment, in millions, when there was a grant received from the fjtap? Call the column fjtap_cap_invest_mil.

SELECT SUM (capital_investment) / 1000000 AS fjtap_cap_invest_mil
FROM ecd 
WHERE fjtap IS NOT NULL;

-- Answer: "$12,634.62"		dont forget to convert into millions by dividing into 1000000

--4.What is the average number of new jobs for each county_tier?

SELECT county_tier, CAST(AVG(new_jobs)AS int)AS avg_new_jobs
FROM ecd
GROUP BY county_tier
ORDER BY county_tier;

-- 1	201
-- 2	128
-- 3	112
-- 4	89

SELECT county_tier, AVG(new_jobs) AS avg_new_jobs_by_county_tier
FROM ecd
GROUP BY county_tier;

-- what Barry did. 

--5.How many companies are LLCs? Call this value llc_companies. (Hint, combine COUNT() and DISTINCT(). Also, consider that LLC may not always be capitalized the same in company names. Find a SQL keyword that can help you with this.)

SELECT COUNT (DISTINCT company)AS llc_companies
FROM ecd
WHERE UPPER (company) LIKE '%LLC%'
OR company LIKE '%llc%';
	
-- 114

SELECT COUNT(DISTINCT company) AS llc_companies
FROM ecd
WHERE company ILIKE '%llc%';

--ILIKE is case in-sensitive      you'll get the same as above with less steps 114 