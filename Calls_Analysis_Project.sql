CREATE DATABASE PROJECT;
-- To work on out database
USE PROJECT;
-- To create a table that will contain the csv file we want to import. 

CREATE TABLE calls (
	ID CHAR(50),
    cust_name CHAR(50),
    sentiment CHAR(20),
    csat_score INT,
    call_timestamp CHAR(10),
    reason CHAR(20),
    city CHAR(20),
    state CHAR(20),
	channels CHAR (20),
    response_time CHAR(20),
    call_duration_minutes INT,
    call_center CHAR(20)
);
-- To show dataset
SELECT * FROM CALLS LIMIT 10;

-- Cleaning the data
-- Defect 1 : call_timestamp is a string, so we need to convert it into date
-- Defect 2 :  csat_score got converted to zero’s instead of null values,because the minimum score is 1 and not 0.
SET SQL_SAFE_UPDATES = 0; -- "WHERE" clause is not specifies as it used a KEY column.
UPDATE calls SET call_timestamp = str_to_date(call_timestamp, "%m/%d/%Y");
UPDATE calls SET csat_score = NULL WHERE csat_score = 0;
SET SQL_SAFE_UPDATES = 1; -- To set it back on after the above 'update' operation.
-- To show dataset
SELECT * FROM CALLS LIMIT 10;

-- EDA(Exploratory Data Analysis)
-- Data Shaping
SELECT COUNT(*) AS rows_num FROM calls;
SELECT COUNT(*) AS cols_num FROM information_schema.columns WHERE table_name = 'calls' ;

-- To Select Distinct Values to heck the different values possible for the rows we selected.
SELECT DISTINCT sentiment FROM calls;
SELECT DISTINCT reason FROM calls;
SELECT DISTINCT channel FROM calls;
SELECT DISTINCT response_time FROM calls;
SELECT DISTINCT call_center FROM calls; 
-- We got only 4 Call-centres.

-- The count and precentage from total of each of the distinct values we got:
SELECT sentiment, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1) AS pct
FROM calls GROUP BY 1 ORDER BY 3 DESC;

SELECT reason, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1) AS pct
FROM calls GROUP BY 1 ORDER BY 3 DESC;
-- Here we can see that Billing Questions amount to a close 71% of all calls, with service outage and payment related calls both are 14.4% of all calls.

SELECT channels, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1) AS pct
FROM calls GROUP BY 1 ORDER BY 3 DESC;

SELECT response_time, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1) AS pct
FROM calls GROUP BY 1 ORDER BY 3 DESC;

SELECT call_center, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1) AS pct
FROM calls GROUP BY 1 ORDER BY 3 DESC;

SELECT state, COUNT(*) FROM calls GROUP BY 1 ORDER BY 2 DESC;

SELECT DAYNAME(call_timestamp) as Day_of_call, COUNT(*) num_of_calls FROM calls GROUP BY 1 ORDER BY 2 DESC;
-- Friday has the most number of calls while Sunday has the least.

-- Aggregations 

SELECT MIN(csat_score) AS min_score, MAX(csat_score) AS max_score, ROUND(AVG(csat_score),1) AS avg_score
FROM calls WHERE csat_score != 0; 

SELECT MIN(call_timestamp) AS earliest_date, MAX(call_timestamp) AS most_recent FROM calls;

SELECT MIN(call_duration_minutes) AS min_call_duration, MAX(call_duration_minutes) AS max_call_duration, AVG(call_duration_minutes) AS avg_call_duration FROM calls;

-- To check how many calls are within / below / above the Service_Level_Agreement_time
SELECT call_center, response_time, COUNT(*) AS count
FROM calls GROUP BY 1,2 ORDER BY 1,3 DESC;
-- Here we see that Chicago/IL call center has around 3359 calls Within SLA , and then Denver/CO has 692 calls below SLA.

SELECT call_center, AVG(call_duration_minutes) FROM calls GROUP BY 1 ORDER BY 2 DESC;

SELECT channel, AVG(call_duration_minutes) FROM calls GROUP BY 1 ORDER BY 2 DESC;

SELECT state, COUNT(*) FROM calls GROUP BY 1 ORDER BY 2 DESC;

SELECT state, reason, COUNT(*) FROM calls GROUP BY 1,2 ORDER BY 1,2,3 DESC;

SELECT state, sentiment , COUNT(*) FROM calls GROUP BY 1,2 ORDER BY 1,3 DESC;

SELECT state, AVG(csat_score) as avg_csat_score FROM calls WHERE csat_score != 0 GROUP BY 1 ORDER BY 2 DESC;

SELECT sentiment, AVG(call_duration_minutes) FROM calls GROUP BY 1 ORDER BY 2 DESC;

-- Window Function to query the maximum call duration each day and then sort by it.
SELECT call_timestamp, MAX(call_duration_minutes) OVER(PARTITION BY call_timestamp) AS max_call_duration FROM calls GROUP BY 1 ORDER BY 2 DESC;
-- Here we see that for example on Oct 4th the maximum call duration was 45 minutes long while on Oct 8th it was 27 minutes long.