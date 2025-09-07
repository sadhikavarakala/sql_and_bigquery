-- 1. Departments with More than 3 employees, ordered by employee count
SELECT
	d.department_name,
	COUNT(e.employee_id) AS num_employees
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
HAVING COUNT(e.employee_id) > 3
ORDER BY num_employees DESC;

-- 2. List top 2 Highest Paid employees per department 
SELECT *
FROM
(SELECT
	e.first_name,
	e.last_name,
	e.salary,
	d.department_name,
	ROW_NUMBER() OVER(PARTITION BY e.department_id ORDER BY e.salary DESC) AS rn
FROM employees e
JOIN departments d ON e.department_id = d.department_id) sub
WHERE rn <= 2 
ORDER BY department_name, salary DESC;

-- 3. Employees earning more than avg salary of their job title
WITH emp_with_job_avg AS(
SELECT 
	e.*,
	j.job_title,
	AVG(e.salary) OVER (PARTITION BY e.job_id) AS job_avg_salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
)
SELECT
	first_name,
	last_name,
	salary,
	job_title,
	job_avg_salary
FROM emp_with_job_avg
WHERE salary > job_avg_salary
ORDER BY job_title, salary DESC;

-- 4. List Employees who work in Different Country than their Manager
SELECT
	e.first_name as Employee_first_name,
	e.last_name as Employee_last_name,
	ec.country_name AS employee_country,
	m.first_name as Manager_first_name,
	m.last_name as Manager_last_name,
	mc.country_name AS manager_country
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
JOIN departments ed ON e.department_id = ed.department_id
JOIN locations el ON ed.location_id = el.location_id
JOIN countries ec ON el.country_id = ec.country_id
JOIN departments md ON m.department_id = md.department_id
JOIN locations ml ON md.location_id = ml.location_id
JOIN countries mc ON ml.country_id = mc.country_id
WHERE ec.country_name <> mc.country_name;

-- 5. Departments where all employees have a salary above the department avg
WITH dept_avg AS (
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
)
SELECT d.department_name
FROM departments d
JOIN employees e ON d.department_id = e.department_id 
JOIN dept_avg da ON e.department_id = da.department_id
GROUP BY d.department_id, d.department_name, da.avg_salary
HAVING MIN(e.salary) > da.avg_salary;

-- 6. For each Manager, list the total num of Employees Managed
SELECT
	m.employee_id AS manager_id,
	m.first_name || ' ' || m.last_name AS manager_name,
	COUNT(e.employee_id) AS num_of_direct_reports
FROM employees m
LEFT JOIN employees e ON e.manager_id = m.employee_id
GROUP BY m.employee_id, manager_name
HAVING COUNT(e.employee_id) > 0
ORDER BY num_of_direct_reports DESC, manager_name;

-- 7. Each Dependent's Name and Their Employee Parent's Department
SELECT 
	d.first_name AS dependent_first_name,
	d.last_name AS dependent_last_name,
	e.first_name AS employee_first_name,
	e.last_name AS employee_last_name,
	dp.department_name
FROM dependents d
JOIN employees e ON d.employee_id = e.employee_id
JOIN departments dp ON e.department_id = dp.department_id
ORDER BY dp.department_name, d.first_name, d.last_name

-- 8. Employees with Same Salary as Someone in a different department
SELECT
	e1.first_name AS emp1_first,
	e1.last_name AS emp1_last,
	d1.department_name AS emp1_dept,
	e2.first_name AS emp2_first,
	e2.last_name AS emp2_last,
	d2.department_name AS emp2_dept,
	e1.salary
FROM employees e1
JOIN employees e2 ON e1.salary = e2.salary AND e1.department_id <> e2.department_id
JOIN departments d1 ON e1.department_id = d1.department_id
JOIN departments d2 ON e2.department_id = d2.department_id
WHERE e1.employee_id < e2.employee_id
ORDER BY e1.salary DESC;


-- 9. Each Country and No. of Employees Working there
SELECT 
	c.country_name,
	COUNT(e.employee_id) AS num_of_employees
FROM countries c
LEFT JOIN locations l ON c.country_id = l.country_id
LEFT JOIN departments d ON l.location_id = d.location_id
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY c.country_name
ORDER BY num_of_employees DESC, c.country_name;

-- 10. Employees w/o Manager (Top Level Exec)
SELECT
	first_name,
	last_name,
	department_id
FROM employees 
WHERE manager_id IS NULL

-- subqueries:
-- Employees who earn more than dept avg
SELECT 
	e.first_name,
	e.last_name,
	e.salary,
	d.department_name
FROM employees e 
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > (
	SELECT avg(salary)
	FROM employees
	WHERE department_id = e.department_id
)
ORDER BY d.department_name, e.salary DESC;

-- list departments with no employees(NOT EXISTS)
SELECT d.department_name
FROM departments d
WHERE NOT EXISTS (
	SELECT 1
	FROM employees e
	WHERE e.department_id = d.department_id
);

-- Index:
CREATE INDEX idx_employees_lastname ON employees(last_name);

--Case Statement
--Salary Category for Employees
SELECT
	first_name,
	last_name,
	salary,
	CASE 
		WHEN salary >= 15000 THEN 'High'
		WHEN salary >= 8000 THEN 'Medium'
		ELSE 'Low'
	END AS salary_category
FROM employees
ORDER BY salary DESC;

-- Trigger
-- creating a logging table
CREATE TABLE salary_changes (
	log_id SERIAL PRIMARY KEY,
	employee_id INT,
	old_salary NUMERIC(8, 2),
	new_salary NUMERIC(8, 2),
	changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.salary <> OLD.salary THEN
		INSERT INTO salary_changes(employee_id, old_salary, new_salary)
		VALUES (NEW.employee_id, OLD.salary, NEW.salary);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger
CREATE TRIGGER trg_salary_update
AFTER UPDATE OF salary ON employees
FOR EACH ROW
EXECUTE FUNCTION log_salary_change();

-- Stored procedures / functions 
-- 1. Give 10% raise to all employees in a department
CREATE OR REPLACE FUNCTION give_raise(dept_id INT, pct DECIMAL)
RETURNS VOID AS $$
BEGIN
	UPDATE employees
	SET salary = salary * (1 + pct)
	WHERE department_id = dept_id;
END;
$$ LANGUAGE plpgsql;

SELECT give_raise(10, 0.10);