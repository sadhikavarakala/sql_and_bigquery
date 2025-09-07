-- Clustering
CREATE OR REPLACE TABLE `silken-forest-466023-a2.stackoverflowtest.testtable_partition_cluster`
PARTITION BY DATE(creation_date)
CLUSTER BY (owner_user_id)
AS
SELECT * 
FROM `silken-forest-466023-a2.stackoverflowtest.testtable`;

SELECT DISTINCT owner_user_id
FROM `silken-forest-466023-a2.stackoverflowtest.testtable_partition_cluster` 
LIMIT 5; -- 15585729

SELECT *
FROM `silken-forest-466023-a2.stackoverflowtest.testtable_partition_cluster`
WHERE owner_user_id = 15585729
  AND creation_date BETWEEN '2022-01-01' AND '2022-01-10';

-- Scheduled Query - automatically run a sql query on schedule (hourly or daily) and write results to a table (useful for summary tables, daily data refresh, dashboards)
-- Example: create scheduled query for new questions asked each day in stackoverflow and save it to summary table

CREATE OR REPLACE TABLE `silken-forest-466023-a2.stackoverflowtest.daily_question_count`
(
  creation_date DATE,
  num_of_ques INT64
);

SELECT 
  DATE(creation_date) AS creation_date,
  COUNT(*) AS num_of_ques
FROM `silken-forest-466023-a2.stackoverflowtest.testtable_partition_cluster`
GROUP BY creation_date
ORDER BY creation_date;


-- Materialised Views - Live summary tables, automatically refreshed when underlying data changes, cheaper than running repeated raw aggregation queries each time
CREATE OR REPLACE MATERIALIZED VIEW `silken-forest-466023-a2.stackoverflowtest.mv_daily_question`
AS
SELECT 
  DATE(creation_date) AS creation_date,
  COUNT(*) AS num_questions
FROM `silken-forest-466023-a2.stackoverflowtest.testtable_partition_cluster`
GROUP BY creation_date;

SELECT *
FROM `silken-forest-466023-a2.stackoverflowtest.mv_daily_question`
ORDER BY creation_date;

-- ALTER - when you want to add columns, delete, modify columns || UPDATE - modify exist rows within a table
ALTER TABLE `silken-forest-466023-a2.stackoverflowtest.testtable`
ADD COLUMN is_weekend BOOL;

UPDATE `silken-forest-466023-a2.stackoverflowtest.testtable`
SET is_weekend =
  EXTRACT(DAYOFWEEK FROM creation_date) IN (1, 7)
WHERE creation_date IS NOT NULL;

SELECT is_weekend
FROM `silken-forest-466023-a2.stackoverflowtest.testtable`
LIMIT 10;

-- MERGE
CREATE OR REPLACE TABLE `silken-forest-466023-a2.stackoverflowtest.sourcetable`
AS
SELECT
  id,
  'UPDATED TITLE' AS title,
  creation_date
FROM silken-forest-466023-a2.stackoverflowtest.testtable
WHERE RAND() < 0.05; -- picks 5% of rows

--MERGE: want to update the title if id matches, and insert if it’s new:
MERGE `silken-forest-466023-a2.stackoverflowtest.testtable` T
USING `silken-forest-466023-a2.stackoverflowtest.sourcetable` S
ON T.id = S.id
WHEN MATCHED THEN
  UPDATE SET title = S.title
WHEN NOT MATCHED THEN
  INSERT (id, title, creation_date) VALUES (s.id, s.title, s.creation_date);