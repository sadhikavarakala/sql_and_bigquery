CREATE TABLE Employee_Demographics
(EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)

CREATE TABLE Employee_Salary
(EmployeeID int,
 JobTitle varchar(50),
 Salary int
)

INSERT INTO Employee_Demographics VALUES
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Felnderson', 32, 'Male'),
(1006, 'Micheal', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male')

INSERT INTO Employee_Salary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 40000),
(1003, 'Salesman', 45000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Manager', 60000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 45000),
(1009, 'Accountant', 47000)

/*

SUBQUERIES (in SELECT, FROM, WHERE, INSERT, UPDATE)

*/

SELECT employeeid, salary, ROUND((SELECT AVG(Salary) FROM employee_salary)) as All_Avg_Salary
FROM employee_salary;


--Partition by
SELECT employeeid, salary, AVG(Salary) over() as All_Avg_Salary
FROM employee_salary;

-- group by & order by
SELECT employeeid, salary, AVG(Salary) as All_Avg_Salary
FROM employee_salary
GROUP BY employeeid, salary
ORDER BY 1, 2
			
-- subquery

SELECT a.employeeid, all_avg_salary
FROM (SELECT employeeid, salary, AVG(Salary) over() as All_Avg_Salary
	  FROM employee_salary) a

-- subuery with where
SELECT employeeid, jobtitle, salary
FROM employee_salary
WHERE employeeid in (
					 SELECT employeeid  
					 FROM employee_demographics
					 WHERE age>30
					)
					
--CTEs - unique, immedeately used under it
WITH cte_example AS
(
SELECT gender, ROUND(AVG(salary)) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count
FROM employee_demographics dem
JOIN employee_salary sal
	on dem.employeeid = sal.employeeid
GROUP BY gender
)
SELECT *
FROM cte_example;

--- Joining two CTEs

WITH cte_1 AS 
(
SELECT employeeid, gender, age
FROM employee_demographics
WHERE age > 32
),
cte_2 AS
(
SELECT employeeid, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT cte_1.employeeid, gender, age, salary
FROM cte_1
JOIN cte_2
ON cte_1.employeeid = cte_2.employeeid



-- Temp Tables -- only visible to the session they are created in
-- use case - for storing intermediate results, for staging before creating permamnent data
-- used for more advanced things vs CTEs used for simple stuff not as complex

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
 last_name varchar(50),
 fav_movie varchar(100)
);

INSERT INTO temp_table
VALUES('Alex', 'Mann', 'Night in the Museeum');

SELECT *
FROM temp_table;

SELECT *
FROM employee_salary;

CREATE TEMPORARY TABLE salary_over50k AS
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT * 
FROM salary_over50k;

/*

Stored Procedure: way to save your sql code so you can use it over and over again,
call it, and it executes - used for storing complex query that you want to resuse

*/

CREATE FUNCTION large_salaries()
RETURNS TABLE(emp_id INT, name TEXT, salary NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT emp_id, name, salary
    FROM employee_salary
    WHERE salary >= 50000;
END;
$$;

/*

Triggers and Events: Trigger takes place automatically when a change takes place on the table

*/

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

-- create trigger function
CREATE OR REPLACE FUNCTION insert_into_demographics()
RETURNS TRIGGER
AS $$
BEGIN 
	INSERT INTO employee_demographics(employeeid)
	VALUES(NEW.employeeid);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER employee_insert
AFTER INSERT ON employee_salary
FOR EACH ROW
EXECUTE FUNCTION insert_into_demographics();

INSERT INTO employee_salary(employeeid, jobtitle, salary)
VALUES(1010, 'Corporate', 70000);

--- Event: event takes place when its scheduled: good for automation

-- Update: 

UPDATE employee_demographics SET employeeid = 1010
WHERE firstname = 'Janet';


--indexing - object that allows you to find specific data in a table faster

--Merge - inserts, updates, deletes in a single statement

SELECT *
FROM employee_salary;

SELECT *
FROM employee_demographics;

-- group by

SELECT gender, COUNT(gender) as no_of_f_m, round(avg(age)) as avg_age
FROM employee_demographics
GROUP BY gender;

SELECT gender, max(age), min(age)
FROM employee_demographics
GROUP BY gender;

--Having vs Where: use having when u want to filter on aggregated columns done in groubby - thats why its comes after groupby

SELECT gender, AVG(age)
FROM employee_demographics 
GROUP BY gender
HAVING AVG(age) >= 38;


-- order by

SELECT *
FROM employee_demographics
ORDER BY 5, 4; --by number of column (not recommended)
 