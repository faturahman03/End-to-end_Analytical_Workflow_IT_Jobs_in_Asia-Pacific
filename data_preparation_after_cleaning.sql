CREATE DATABASE itjob;
USE itjob;

CREATE TABLE itjob_header (
    jobid INT PRIMARY KEY,
    level VARCHAR(100),
    tech_specialisation VARCHAR(255),
    country VARCHAR(100),
    salary_from DECIMAL(12,2),
    salary_to DECIMAL(12,2),
    currency VARCHAR(10),
    type VARCHAR(50),
    mode VARCHAR(50),
    visa_sponsorship VARCHAR(50),
    work_experience_years DECIMAL(4,1),
    education_level VARCHAR(100)
);
CREATE TABLE itjob_main (
    jobid INT,
    source_classification VARCHAR(255),
    FOREIGN KEY (jobid) REFERENCES itjob_header(jobid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE itjob_tools (
    tool_id INT PRIMARY KEY,
    jobid INT,
    tool_text VARCHAR(255),
    FOREIGN KEY (jobid) REFERENCES itjob_header(jobid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE itjob_prog_lang (
    prog_lang_id INT PRIMARY KEY,
    jobid INT,
    prog_lang_text VARCHAR(255),
    FOREIGN KEY (jobid) REFERENCES itjob_header(jobid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE itjob_main_spec (
    addit_spec_id INT PRIMARY KEY,
    jobid INT,
    addit_spec_text VARCHAR(255),
    FOREIGN KEY (jobid) REFERENCES itjob_header(jobid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE itjob_certification (
    cert_id INT PRIMARY KEY,
    jobid INT,
    certification_text VARCHAR(255),
    is_mandatory TINYINT(1),
    FOREIGN KEY (jobid) REFERENCES itjob_header(jobid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hasil_cleaning_header.csv'
INTO TABLE itjob_header
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(jobid, level, tech_specialisation, country, salary_from, salary_to, currency, type, mode, visa_sponsorship, work_experience_years, education_level);

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/itjob_tools.csv'
INTO TABLE itjob_tools
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tool_id, jobid, tool_text);

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/itjob_prog_lang.csv'
INTO TABLE itjob_prog_lang
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(prog_lang_id, jobid, prog_lang_text);

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/itjob_main_spec.csv'
INTO TABLE itjob_main_spec
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(addit_spec_id, jobid, addit_spec_text);

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/itjob_certification.csv'
INTO TABLE itjob_certification
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cert_id, jobid, certification_text, is_mandatory);

CREATE TABLE exchange_rate (
  currency_code VARCHAR(10) PRIMARY KEY,
  rate_to_usd DECIMAL(10,6)
);

INSERT INTO exchange_rate (currency_code, rate_to_usd) VALUES
('PHP', 0.017040),
('SGD', 0.772700),
('MYR', 0.238600),
('IDR', 0.0000602),
('AUD', 0.659900),
('NZD', 0.578400),
('HKD', 0.128700),
('THB', 0.030910),
('USD', 1.000000),
('GBP', 1.321600),
('FJD', 0.437000),
('JPY', 0.006576),
('MXN', 0.054200);

ALTER TABLE itjob_header
ADD COLUMN avg_salary_usd DECIMAL(12,2);

ALTER TABLE itjob_header ADD COLUMN avg_salary DECIMAL(12,2);

UPDATE itjob_header h
JOIN (
    SELECT jobid,
           ROUND(AVG((salary_from + salary_to)/2), 2) AS avg_salary
    FROM itjob_header
    GROUP BY jobid
) s ON h.jobid = s.jobid
SET h.avg_salary = s.avg_salary;

select * from exchange_rate;
SELECT * FROM itjob_header;	

SET SQL_SAFE_UPDATES = 0;
UPDATE itjob_header h
JOIN exchange_rate r ON h.currency = r.currency_code
SET h.avg_salary_usd = h.avg_salary * r.rate_to_usd;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE itjob_header
ADD COLUMN avg_salary_usd DECIMAL(12,2);

ALTER TABLE itjob_header ADD COLUMN avg_salary DECIMAL(12,2);

UPDATE itjob_header h
JOIN (
    SELECT jobid,
           ROUND(AVG((salary_from + salary_to)/2), 2) AS avg_salary
    FROM itjob_header
    GROUP BY jobid
) s ON h.jobid = s.jobid
SET h.avg_salary = s.avg_salary;

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

/*
Case Objective:
    To analyze the most in-demand tools and programming languages 
    in IT job vacancies, particularly in the data field, 
    and explore their relationships with salary, level, and work location.
*/ 

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

#Next, save to csv for visualize in excel and tableau
