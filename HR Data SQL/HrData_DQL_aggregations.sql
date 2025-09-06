-- Count of employees in each department
SELECT d.department_name, COUNT(e.employee_id) AS num_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY num_employees DESC;

-- Avg Salary by Job title
SELECT j.job_title, ROUND(AVG(e.salary), 2) AS avg_salary
FROM jobs j
JOIN employees e ON j.job_id = e.job_id
GROUP BY j.job_title
ORDER BY avg_salary DESC;

-- Total num of Dependents per Employee (with Names)
SELECT e.first_name, e.last_name, COUNT(d.dependent_id) AS num_dependents
FROM employees e
LEFT JOIN dependents d ON e.employee_id = d.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY num_dependents DESC;

-- Highest, lowest, Avg Salary By Department
SELECT 
	d.department_name,
	MAX(e.salary) AS max_salary,
	MIN(e.salary) AS min_salary,
	ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- Departments with Avg Salary greater than $10,000
SELECT 
	d.department_name,
	ROUND(AVG(e.salary),2) AS avg_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
HAVING AVG(e.salary) > 10000;