SELECT *
FROM employee_compensation_json;

-- JSON DATA: Pulling top level fields
SELECT
	json_id, 
	json_column ->>'POSITION' AS position,
	json_column ->>'SCHOOL' AS school,
	json_column ->>'MAJOR' AS major
FROM employee_compensation_json;

-- Pulling nested fields 

SELECT
	json_id,
	(json_column ->'COMPENSATION'->>'BONUS'):: numeric AS bonus,
	(json_column ->'COMPENSATION'->>'SALARY') :: numeric AS salary,
	(json_column ->'COMPENSATION'->>'VACATION') :: int AS vacation_days
FROM employee_compensation_json;

-- Aggregation
SELECT
	ROUND(SUM((json_column ->'COMPENSATION'->>'SALARY') :: numeric)) AS salary
FROM employee_compensation_json;

-- JSONB_BUILD_ARRAY - pull the entire array as object
SELECT
	jsonb_build_array(json_column ->'COMPENSATION') AS comp_array
FROM employee_compensation_json;

-- Turning JSON into columns (jsonb_to_record)
SELECT ecj.json_id, t.*
FROM employee_compensation_json ecj,
LATERAL jsonb_to_record(ecj.json_column) AS t(
	"POSITION" text,
	"SCHOOL" text,
	"MAJOR" text,
	"COMPENSATION" jsonb
);

-- Breaking compensation out too
SELECT 
	ecj.json_id,
	j."POSITION",
	j."SCHOOL",
	j."MAJOR",
	(j."COMPENSATION"->>'SALARY')::numeric AS salary,
	(j."COMPENSATION"->>'BONUS')::numeric AS bonus,
	(j."COMPENSATION"->>'VACATION')::int AS vacation_days
FROM employee_compensation_json ecj,
LATERAL jsonb_to_record(ecj.json_column) AS j(
	"POSITION" text,
	"SCHOOL" text,
	"MAJOR" text,
	"COMPENSATION" jsonb
);

