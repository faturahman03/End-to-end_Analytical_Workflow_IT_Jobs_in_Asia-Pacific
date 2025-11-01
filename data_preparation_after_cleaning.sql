USE itjob;

/*
Case Objective:
    To analyze the most in-demand tools and programming languages 
    in IT job vacancies, particularly in the data field, 
    and explore their relationships with salary, level, and work location.
Note:
    A single jobid can have more than one tool_name or programming_language.
*/ 

WITH salary_calc AS (
    SELECT
        jobid,
        ROUND(AVG((salary_from + salary_to)/2), 2) AS avg_salary
    FROM itjob_header
    WHERE salary_from IS NOT NULL
    GROUP BY jobid
)
-- CTE is used here because we only need to GROUP BY jobid.

SELECT 
	h.jobid,
	h.level,
	h.tech_specialisation AS data_specialisation,
	h.country,
	s.avg_salary,
    h.avg_salary_usd,
	h.currency,
	h.type AS type_employment,
	h.mode AS work_mode,
	m.source_classification AS job_classification,
	p.prog_lang_text AS programming_language,
	t.tool_text AS tool_name
FROM itjob_header h
INNER JOIN itjob_main m ON h.jobid = m.jobid		
INNER JOIN itjob_prog_lang p ON h.jobid = p.jobid	-- INNER JOIN is used since the goal is to analyze the frequency of required programming languages.
INNER JOIN itjob_tools t ON h.jobid = t.jobid		-- INNER JOIN is used since the goal is to analyze the frequency of required tools.
INNER JOIN salary_calc s ON h.jobid = s.jobid
;			-- Filtering is applied to focus on job specializations in the data field.


-- Exploring the relationship between salary and country, as well as the number of data-related jobs
WITH salary_calc AS (
    SELECT
        jobid,
        ROUND(AVG((salary_from + salary_to)/2), 2) AS avg_salary
    FROM itjob_header
    WHERE salary_from IS NOT NULL
    GROUP BY jobid
)
SELECT 
    h.jobid,
    h.level,
    h.tech_specialisation AS data_specialisation,
    h.country,
    s.avg_salary,
    h.currency,
    h.avg_salary_usd,
    h.type AS type_employment,
	h.mode AS work_mode,
    m.source_classification AS job_classification,
    GROUP_CONCAT(DISTINCT p.prog_lang_text ORDER BY p.prog_lang_text SEPARATOR ', ') AS programming_languages,
    GROUP_CONCAT(DISTINCT t.tool_text ORDER BY t.tool_text SEPARATOR ', ') AS tools_used,
    h.education_level
FROM itjob_header h
INNER JOIN itjob_main m ON h.jobid = m.jobid
INNER JOIN itjob_prog_lang p ON h.jobid = p.jobid
INNER JOIN itjob_tools t ON h.jobid = t.jobid
INNER JOIN salary_calc s ON h.jobid = s.jobid
WHERE h.avg_salary_usd IS NOT NULL
GROUP BY h.jobid, m.source_classification
;


# Check and remove duplicate rows based on jobid and tool_text

SELECT * 
FROM itjob_prog_lang;

SELECT jobid, prog_lang_text, COUNT(*) AS count_duplicates
FROM itjob_prog_lang
GROUP BY jobid, prog_lang_text
HAVING COUNT(*) > 1;

SELECT prog_lang_id, jobid, prog_lang_text
FROM itjob_prog_lang
WHERE jobid = '81';

# Using CTE with partition to identify and remove duplicate records 
# based on jobid and prog_lang_text columns.
WITH ranked_tools AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY jobid, prog_lang_text ORDER BY prog_lang_id) AS rn
  FROM itjob_prog_lang
)
DELETE FROM itjob_prog_lang
WHERE prog_lang_id IN (
  SELECT prog_lang_id
  FROM ranked_tools
  WHERE rn > 1
);
