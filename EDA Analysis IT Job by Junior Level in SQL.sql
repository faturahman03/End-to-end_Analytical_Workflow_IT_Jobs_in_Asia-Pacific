USE itjob;

/* Analysis of IT Jobs at the Junior Level */


			## Most Required Job Roles
SELECT 
  m.source_classification AS title_job,
  COUNT(m.jobid) AS count_job
FROM itjob_main m
INNER JOIN itjob_header h
ON m.jobid = h.jobid
WHERE h.level = 'Junior'
GROUP BY m.source_classification
ORDER BY count_job DESC
LIMIT 10;
/*
The most required job role is Help Desk & IT Support, with a total of 119 listings.
*/


			## Top 10 Most Required Job Specialisations under 'Help Desk & IT Support' Classification, Including Maximum Salary for Junior Level
SELECT 
  h.tech_specialisation AS job_specialisation,
  COUNT(h.jobid) AS count_job,
  MAX(h.avg_salary_usd) AS max_salary
FROM itjob_header h
INNER JOIN itjob_main m ON m.jobid = h.jobid
WHERE m.source_classification LIKE '%Help Desk & IT Support%'
  AND h.tech_specialisation IS NOT NULL
  AND h.tech_specialisation <> ''
  AND h.level = 'Junior'
GROUP BY h.tech_specialisation
HAVING MAX(h.avg_salary_usd) > 0
ORDER BY count_job DESC, max_salary DESC
LIMIT 10;
/*
IT Support is the most demanded job specialisation with 39 job openings, followed by Help Desk (8) and Help Desk & IT Support (6).
The highest maximum salary for the Junior level is found in the IT Support role, with a salary of $59,391.00 compared to other job specialisations.
*/


			## Which Countries Require the Most IT Support Jobs? What Is the Average Salary?
SELECT 
  h.country,
  COUNT(DISTINCT h.jobid) AS count_job_it_support,
  ROUND(AVG(h.avg_salary_usd), 2) AS avg_salary
FROM itjob_header h
INNER JOIN itjob_main m ON m.jobid = h.jobid
WHERE m.source_classification LIKE '%Help Desk & IT Support%'
  AND h.level = 'Junior'
  AND h.tech_specialisation = 'IT Support'
  AND h.country IS NOT NULL
  AND TRIM(h.country) <> ''
GROUP BY h.country
ORDER BY count_job_it_support DESC, avg_salary DESC;
/*
Indonesia has the highest demand for IT Support positions with 10 job postings,
followed by Australia, Hong Kong, and the Philippines, each with 6 job openings.
*/


			## What Programming Languages Are Most Commonly Used by IT Support (Junior Level)?
SELECT 
  l.prog_lang_text AS programming_language,
  COUNT(m.jobid) AS count_prog_lang
FROM itjob_main m
LEFT JOIN itjob_header h ON m.jobid = h.jobid
LEFT JOIN itjob_prog_lang l ON m.jobid = l.jobid
WHERE m.source_classification LIKE '%Help Desk & IT Support%'
  AND h.level = 'Junior'
  AND h.tech_specialisation = 'IT Support'
GROUP BY l.prog_lang_text
ORDER BY count_prog_lang DESC;
		-- Persentage count of nulls in programming_language devided by sum of count_prog_lang
WITH lang_counts AS (
  SELECT 
    l.prog_lang_text AS programming_language,
    COUNT(m.jobid) AS count_prog_lang
  FROM itjob_main m
  LEFT JOIN itjob_header h ON m.jobid = h.jobid
  LEFT JOIN itjob_prog_lang l ON m.jobid = l.jobid
  WHERE m.source_classification LIKE '%Help Desk & IT Support%'
    AND h.level = 'Junior'
    AND h.tech_specialisation = 'IT Support'
  GROUP BY l.prog_lang_text
)
SELECT
  SUM(CASE WHEN programming_language IS NULL THEN count_prog_lang ELSE 0 END) AS null_count,
  SUM(count_prog_lang) AS total_count,
  ROUND(
    100.0 * SUM(CASE WHEN programming_language IS NULL THEN count_prog_lang ELSE 0 END) 
    / SUM(count_prog_lang), 
    2
  ) AS null_percentage
FROM lang_counts;
/*
SQL is the most frequently required programming language.
However, there are 33 missing rows (around 80.49% of the data), 
which indicates that the data might not fully represent the actual situation.
*/


			## What Tools Are Commonly Used by IT Support Professionals?
SELECT 
  t.tool_text AS tool_name,
  COUNT(m.jobid) AS count_tools
FROM itjob_main m
LEFT JOIN itjob_header h ON m.jobid = h.jobid
LEFT JOIN itjob_tools t ON m.jobid = t.jobid
WHERE m.source_classification LIKE '%Help Desk & IT Support%'
  AND h.level = 'Junior'
  AND h.tech_specialisation = 'IT Support'
GROUP BY t.tool_text
ORDER BY count_tools DESC;
		-- Persentage count of nulls in tool_name devided by sum of count_tools
WITH tools_count AS (
	SELECT 
	  t.tool_text AS tool_name,
	  COUNT(m.jobid) AS count_tools
	FROM itjob_main m
	LEFT JOIN itjob_header h ON m.jobid = h.jobid
	LEFT JOIN itjob_tools t ON m.jobid = t.jobid
	WHERE m.source_classification LIKE '%Help Desk & IT Support%'
	  AND h.level = 'Junior'
	  AND h.tech_specialisation = 'IT Support'
	GROUP BY t.tool_text
	ORDER BY count_tools DESC
)
SELECT
  SUM(CASE WHEN tool_name IS NULL THEN count_tools ELSE 0 END) AS null_count,
  SUM(count_tools) AS total_count,
  ROUND(
    100.0 * SUM(CASE WHEN tool_name IS NULL THEN count_tools ELSE 0 END) 
    / SUM(count_tools), 
    2
  ) AS null_percentage
FROM tools_count;
/*
MS Office is the most commonly required tool (6 occurrences), 
followed by CCTV (4) and TCP/IP (3).
There are 15 missing rows (14.56% of the total data), 
but the dataset can still be considered fairly representative of real-world conditions.
*/
