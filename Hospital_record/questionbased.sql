SELECT * from encounters;

-- Use encounters table only. other table doesnt seems necessary
-- OBJECTIVE 1: ENCOUNTERS OVERVIEW
-- a. How many total encounters occurred each year?

SELECT 
YEAR(START) AS year,
COUNT(Id) AS count_year
FROM encounters
GROUP BY YEAR;

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?

SELECT 
Year(Start) AS year,
ENCOUNTERCLASS,
COUNT(Id) AS Count_encounterclass,
ROUND(COUNT(Id) * 100.0 / SUM(COUNT(Id)) OVER (PARTITION BY YEAR(Start)), 2) AS percentage
FROM encounters
GROUP BY year, ENCOUNTERCLASS
ORDER BY year, ENCOUNTERCLASS;


-- c. What percentage of encounters were over 24 hours versus under 24 hours?
-- over_24/under_24*100

SELECT 
	SUM(CASE WHEN TIMESTAMPDIFF(MINUTE,START,STOP) > 1440 THEN 1 ELSE 0 END) AS over_24,
	SUM(CASE WHEN TIMESTAMPDIFF(MINUTE,START,STOP) < 1440 THEN 1 ELSE 0 END) AS under_24,
	ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MINUTE,START,STOP) > 1440 THEN 1 ELSE 0 END)/ 
	SUM(CASE WHEN TIMESTAMPDIFF(MINUTE,START,STOP) < 1440 THEN 1 ELSE 0 END)*100,2) AS percentage
FROM encounters;

-- OBJECTIVE 2: COST & COVERAGE INSIGHTS
-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?

SELECT 
COUNT(IF(payer_coverage = 0,1,NULL)) AS 0_payer_cov,
COUNT(payer_coverage) AS total_payer_cov,
ROUND((COUNT(IF(payer_coverage = 0,1,NULL))/COUNT(payer_coverage))*100,2) AS percentage
FROM encounters;

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?

SELECT
	DISTINCT(description),
    COUNT(*) AS count_descrip,
    ROUND(AVG(base_encounter_cost),2) AS avg_base_encounter_cost	
FROM encounters 
GROUP BY description
ORDER BY count_descrip DESC
LIMIT 10;

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?

SELECT
	DISTINCT(description),
    ROUND(AVG(base_encounter_cost),2) AS avg_base_encounter_cost,
	COUNT(*) AS count_descrip
FROM encounters 
GROUP BY description
ORDER BY avg_base_encounter_cost DESC,count_descrip DESC
LIMIT 10;

-- d. What is the average total claim cost for encounters, broken down by payer?

SELECT 
	DISTINCT(payer),
	ROUND(AVG(total_claim_cost),2) AS avg_total_claim_cost
FROM encounters
GROUP BY payer;

-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS
-- a. How many unique patients were admitted each quarter over time?

SELECT QUARTER(START) AS quarter,COUNT(DISTINCT PATIENT) AS count_dist_patient
FROM encounters
GROUP BY quarter
ORDER BY quarter;

-- b. How many patients were readmitted within 30 days of a previous encounter?
-- Id also refers to encounter
-- CTE is to have a column of 'stop' minus 'next start'. and partition by patient 

WITH datediff_lag AS (
SELECT 
	patient,
    Start,
    Stop,
    LAG(STOP) OVER (PARTITION BY patient ORDER BY Start) AS prev_stop,
    DATEDIFF(Stop,LAG(STOP) OVER (PARTITION BY patient ORDER BY Start)) AS datediff
FROM encounters
)
SELECT COUNT(DISTINCT patient) 
    FROM datediff_lag
    WHERE datediff < 30;

-- c. Which patients had the most readmissions?
-- Reuse previous datediff_lag CTE, but abandon the idea of readmission is more than 30 days only

WITH datediff_lag AS (
SELECT 
	patient,
    Start,
    Stop,
    LAG(STOP) OVER (PARTITION BY patient ORDER BY Start) AS prev_stop,
    DATEDIFF(Stop,LAG(STOP) OVER (PARTITION BY patient ORDER BY Start)) AS datediff
FROM encounters
) 
SELECT 
patient,
COUNT(*) AS readmission_count
FROM datediff_lag
GROUP BY patient
ORDER BY readmission_count DESC;

--
