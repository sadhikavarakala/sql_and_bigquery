-- Complex Join
-- List each employee with their department, office city, and country

SELECT 
	e.first_name,
	e.last_name,
	d.department_name,
	l.city,
	c.country_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
ORDER BY c.country_name, d.department_name, e.last_name;

-- For each employee show their manager's name(if any)

SELECT 
	e.first_name || ' ' || e.last_name AS employee,
	m.first_name || ' ' || m.last_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY manager, employee;

-- Employees with no dependents 
SELECT 
	e.first_name,
	e.last_name
FROM employees e
LEFT JOIN dependents d ON e.employee_id = d.employee_id
WHERE d.dependent_id IS NULL;

-- List Departments and Employee Count, including Departments with Zero Employees
SELECT 
	d.department_name,
	COUNT(e.employee_id) AS num_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY num_employees DESC, d.department_name;

SELECT * 
FROM regions

-- Employees and the City/Region of their Office
SELECT 
	e.first_name,
	e.last_name,
	l.city,
	r.region_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
JOIN regions r ON c.region_id = r.region_id
ORDER BY r.region_name, l.city, e.last_name;

-- All Managers who have no dependents
SELECT
	m.employee_id,
	m.first_name,
	m.last_name
FROM employees e
JOIN employees m on e.manager_id = m.employee_id
LEFT JOIN dependents d ON m.employee_id = d.employee_id
WHERE d.dependent_id IS NULL;
