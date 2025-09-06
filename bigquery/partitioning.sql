CREATE OR REPLACE TABLE `silken-forest-466023-a2.stackoverflowtest.testtable`
AS
SELECT *
FROM `bigquery-public-data.stackoverflow.posts_questions` 
WHERE creation_date BETWEEN '2022-01-01' AND '2022-01-10'
LIMIT 10000;

SELECT * FROM `silken-forest-466023-a2.stackoverflowtest.testtable` LIMIT 10;

CREATE OR REPLACE TABLE `silken-forest-466023-a2.stackoverflowtest.testtable_partitioned`
PARTITION BY DATE(creation_date)
AS
SELECT * 
FROM `silken-forest-466023-a2.stackoverflowtest.testtable`;

SELECT COUNT(*) AS total
FROM `silken-forest-466023-a2.stackoverflowtest.testtable`
WHERE creation_date BETWEEN '2022-01-05' AND '2022-01-05 23:59:59';  --This query will process 78.13 KB when run.

SELECT COUNT(*) AS total
FROM `silken-forest-466023-a2.stackoverflowtest.testtable_partitioned`
WHERE creation_date BETWEEN '2022-01-05' AND '2022-01-05 23:59:59'; -- This query will process 11.72 KB when run.


