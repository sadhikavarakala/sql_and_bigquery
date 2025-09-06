-- ROW_NUMBER() - Number of Employees within each Department by Salary
SELECT 
	e.first_name,
	e.last_name,
	d.department_name,
	e.salary,
	ROW_NUMBER() OVER(
	PARTITION BY d.department_name
	ORDER BY e.salary DESC) AS salary_rank
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name, salary_rank;

-- RANK() - Rank employees by Salary within each Department
SELECT 
	e.first_name,
	e.last_name,
	d.department_name,
	e.salary,
	RANK() OVER(
	PARTITION BY d.department_name
	ORDER BY e.salary DESC) AS salary_rank
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name, salary_rank;

-- DENSE RANK() - like rank, but no gaps
SELECT 
	e.first_name,
	e.last_name,
	d.department_name,
	e.salary,
	DENSE_RANK() OVER(
	PARTITION BY d.department_name
	ORDER BY e.salary DESC) AS salary_rank
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name, salary_rank;

-- Top 2 Salaries per Department
SELECT *
FROM
(
	SELECT
	e.*,
	d.department_name,
	ROW_NUMBER() OVER(
	PARTITION BY e.department_id
	ORDER BY e.salary DESC) AS rn
FROM employees e
JOIN departments d ON e.department_id = d.department_id
) sub
WHERE rn <= 2;


-- Employees earning more than department Average
WITH emp_with_dept_avg AS (
SELECT 
	e.first_name,
	e.last_name,
	d.department_name,
	e.salary,
	AVG(e.salary) OVER (PARTITION BY e.department_id) AS dept_avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
)
SELECT *
FROM emp_with_dept_avg
WHERE salary > dept_avg_salary
ORDER BY department_name, salary DESC;
