-- 1. 
-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS sum_claims
FROM prescription
GROUP BY npi
ORDER BY sum_claims DESC;

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT  SUM (total_claim_count) as sum_claims,
		nppes_provider_first_name, 
		nppes_provider_last_org_name, 
		specialty_description
FROM prescription 
INNER JOIN prescriber 
USING (npi)
GROUP BY nppes_provider_first_name, 
		nppes_provider_last_org_name, 
		specialty_description
ORDER BY sum_claims DESC;
--check tommy's 
--why again does he not alias?

-- 2. 
-- a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT SUM(rx.total_claim_count) AS sum_claims, 
		dr.specialty_description
FROM prescription AS rx
INNER JOIN prescriber AS dr
on rx.npi = dr.npi
GROUP BY dr.specialty_description
ORDER BY sum_claims DESC
LIMIT 1; 

-- b. Which specialty had the most total number of claims for opioids?

SELECT SUM(rx.total_claim_count) AS sum_claims, 
		dr.specialty_description
FROM prescription AS rx
INNER JOIN prescriber AS dr
ON rx.npi = dr.npi
INNER JOIN drug
ON rx.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY dr.specialty_description
ORDER BY sum_claims DESC;

-- c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT SUM(rx.total_claim_count) AS sum_claims, 
		dr.specialty_description
FROM prescriber AS dr
LEFT JOIN prescription AS rx
ON rx.npi = dr.npi
GROUP BY dr.specialty_description
HAVING SUM(rx.total_claim_count) IS NULL;
--Tommy's was simple and used a lot of cut/paste from 2b. 

(select specialty_description, count(drug_name) as presciption_count
from prescriber
left join prescription
	using (npi)
group by specialty_description)
except
(select specialty_description, count(drug_name)
from prescriber
left join prescription
	using (npi)
where drug_name is not null
group by specialty_description);
--Isabelle Pethtel

SELECT specialty_description
FROM prescriber
GROUP BY specialty_description
EXCEPT
SELECT specialty_description
FROM prescriber
JOIN prescription
USING (npi)
GROUP BY specialty_description;
--Ava Melzak

-- d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
--so which speciality has the highest percentage of opioids claims 

SELECT  
		dr.specialty_description,
		-- going to want the total of opioids prescribed / total claims
		--so do total claims side first 
		--to get total of opioids use a case statement 
		--case says only get the sum when the opioid is Y
		--ROUND to get a readable percentage 
		ROUND((SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)/SUM(total_claim_count) * 100), 2) AS percent_opioid
FROM prescriber AS dr
LEFT JOIN prescription USING (npi)
LEFT JOIN drug USING (drug_name)
GROUP BY specialty_description
ORDER BY percent_opioid DESC NULLS LAST;

WITH opioids AS (
	SELECT specialty_description,
		SUM(total_claim_count) AS total_opioid
	FROM drug
	JOIN prescription USING (drug_name) 
	join prescriber USING (npi)
	WHERE opioid_drug_flag = 'Y'
	GROUP BY specialty_description
	order by total_opioid desc
	)
SELECT specialty_description,
	ROUND((total_opioid/SUM(total_claim_count)*100), 2) AS opioid_percent
FROM prescriber
JOIN prescription
USING (npi)
JOIN opioids
USING (specialty_description)
GROUP BY specialty_description, total_opioid
ORDER BY opioid_percent DESC;
--Ava Melzak's ---she counted the drug names so we switched to SUM



-- 3. 
-- a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost)::MONEY AS total_cost 
FROM drug
INNER JOIN prescription 
USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC; 


-- b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.


SELECT generic_name, ROUND(SUM(total_drug_cost) / SUM(total_day_supply),2)::MONEY AS total_cost_per_day 
FROM drug
INNER JOIN prescription 
USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day DESC; 


--4. 
-- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name, 
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opiod'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		WHEN antipsychotic_drug_flag = 'Y' THEN 'neither' 
		ELSE 'neither'
	END AS special_drugs
FROM drug;

-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

WITH op_or_anti AS ( 
SELECT drug_name,
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		WHEN antipsychotic_drug_flag = 'Y' THEN 'neither' 
		ELSE 'neither'
	END AS special_drugs,
	SUM(prescription.total_drug_cost)::MONEY AS total_cost
FROM drug
INNER JOIN prescription 
USING (drug_name)
GROUP BY  special_drugs, drug.drug_name
ORDER BY special_drugs, total_cost
)
SELECT SUM(total_cost) AS spent, special_drugs
FROM op_or_anti
WHERE special_drugs = 'opioid' OR special_drugs = 'antibiotic'
GROUP BY special_drugs;

-- 5. 
-- a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT cbsa, cbsaname
FROM cbsa 
WHERE cbsaname LIKE '%TN';
--get more familar with the data because if you used fpscounty data you'd get 10 

-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsa.cbsa,
		SUM(population.population)AS cbsa_total_pop,
		cbsaname
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
INNER JOIN population 
USING (fipscounty)
GROUP BY cbsa, cbsaname
ORDER BY cbsa_total_pop DESC; 
 
-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT cbsaname, max_population.max_pop
FROM (SELECT DISTINCT fipscounty,
		MAX(population) AS max_pop
FROM population
LEFT JOIN cbsa
USING (fipscounty)
GROUP BY fipscounty
ORDER BY max_pop DESC) AS max_population
	INNER JOIN cbsa
	USING (fipscounty)
	GROUP BY cbsaname, max_population.max_pop;
--needs work 

SELECT *
FROM fips_county
INNER JOIN population 
USING (fipscounty)
WHERE fipscounty NOT IN (SELECT fipscounty FROM cbsa)
ORDER BY population DESC;
--Tommy


SELECT county, population
FROM population
INNER JOIN fips_county
USING(fipscounty)
EXCEPT
SELECT county, population
FROM cbsa
INNER JOIN population
USING (fipscounty)
INNER JOIN fips_county
USING(fipscounty)
ORDER BY population DESC
LIMIT 1;
--Juan Doza 

WITH county_data AS (
    SELECT fc.county AS county_name_non_cbsa, 
        p.population AS county_pop_non_cbsa
    FROM fips_county fc
    JOIN population p USING (fipscounty) 
    LEFT JOIN cbsa c USING (fipscounty)
    WHERE fc.state = 'TN'
    AND c.fipscounty IS NULL
    ORDER BY county_pop_non_cbsa DESC
    LIMIT 1)

SELECT county_name_non_cbsa, 
	   county_pop_non_cbsa AS max_population 
FROM county_data;
--Zach hoffman 


SELECT  f.county,f.state,
p.population
FROM population p
JOIN fips_county f 
ON p.fipscounty = f.fipscounty
LEFT JOIN cbsa c 
ON f.fipscounty = c.fipscounty
WHERE c.cbsa IS NULL
ORDER BY p.population DESC
LIMIT 1;
--Cyrus Gilchrist


-- 6. 
-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT DISTINCT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000; 

-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT total_claim_count, drug_name, drug.opioid_drug_flag
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000;

-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT total_claim_count, drug_name, drug.opioid_drug_flag, 
	prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name
FROM prescription
INNER JOIN drug USING (drug_name)
INNER JOIN prescriber ON prescriber.npi = prescription.npi
WHERE total_claim_count >= 3000;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug.drug_name
FROM prescriber 
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y';

-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

WITH pain_mgmt AS (
SELECT npi, drug.drug_name
FROM prescriber 
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y'
	)
SELECT pain_mgmt.npi, pain_mgmt.drug_name, total_claim_count
FROM pain_mgmt
LEFT JOIN prescription
USING (npi, drug_name);

-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

WITH pain_mgmt AS (
SELECT npi, drug.drug_name
FROM prescriber 
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y'
	)
SELECT pain_mgmt.npi, 
		pain_mgmt.drug_name, 
		total_claim_count,
		COALESCE(prescription.total_claim_count, 0) as total_claim_count
FROM pain_mgmt
LEFT JOIN prescription
USING (npi, drug_name); 

select 
	npi, drug.drug_name,
	coalesce (total_claim_count, 0) as total_claims
from prescriber 
cross join drug
left join prescription using (npi,drug_name)
where specialty_description = 'Pain Managment' and nppes_provider_city = 'NASHVILLE' and opioid_drug_flag = 'Y'
order by total_claims desc; 



