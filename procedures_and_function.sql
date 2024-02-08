-- 1. Create the proc1 procedure which, using the cursor, will print the names of cities where the real maximum earnings
-- of employees are lower than the given amount. Call it with parameter 10000.
CREATE OR ALTER PROCEDURE proc1 @amount NUMERIC(8,2)
AS
BEGIN
    DECLARE @city VARCHAR(30);
    DECLARE cur CURSOR
    FOR SELECT l.city
        FROM locations l
        JOIN departments d ON l.location_id = d.location_id
        JOIN employees e ON d.department_id = e.department_id
        GROUP BY l.city
        HAVING max(e.salary) < @amount;

    OPEN cur;
    FETCH NEXT FROM cur INTO @city;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @city;
        FETCH NEXT FROM cur INTO @city;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;

EXEC proc1 10000;

-- 2. Create a proc2 procedure that adds information about the new department to the database. The ID of the new department
-- must be automatically calculated in accordance with the principle of assigning IDs to departments. The department name
-- must be provided as a procedure parameter. Manager ID has no value entered by default, but it can be provided as a
-- procedure parameter. The location ID has a default value of 2000, but you can also provide a different value as a
-- procedure parameter. Call the proc2 procedure in all possible ways to test the operation of the default parameters.
CREATE OR ALTER PROCEDURE proc2 @dep_name VARCHAR(30),
                       @mng_id NUMERIC(6) = NULL,
                       @loc_id NUMERIC(4) = 2000
AS
BEGIN
    DECLARE @max_id NUMERIC(4);

    SELECT @max_id = MAX(department_id) FROM departments;

    INSERT INTO departments(department_id, department_name, manager_id, location_id)
    VALUES (@max_id + 10, @dep_name, @mng_id, @loc_id);
END;

EXEC proc2 'dep_1';
EXEC proc2 'dep_2', 100;
EXEC proc2 'dep_3', @loc_id = 1200;
EXEC proc2 'dep_4', 100, 1200;

-- 3. Create the proc3 procedure, which will increase the commission by a given number of percentage points for employees
-- employed before the given year and return the number of modified records via the output parameter. Call it with parameters
-- 2004 and 5.
CREATE OR ALTER PROCEDURE proc3 @percent_inc INT,
                       @year INT,
                       @rows_modified INT OUT
AS
BEGIN
    UPDATE employees
    SET commission_pct = coalesce(commission_pct, 0) + cast(@percent_inc AS FLOAT) / 100.0
    WHERE datepart(year, hire_date) < @year;

    SET @rows_modified = @@ROWCOUNT;
END;

BEGIN
    DECLARE @row_count INT;

    EXEC proc3 5, 2004, @row_count OUT;

    PRINT concat(@row_count, ' row(s) affected.')
END;

-- 4. Create the function func4, which will return the percentage of the number of employees employed in the given department
-- in the total number of all employees. Round the result to the nearest hundredth. Call it for all departments inside a
-- query that produces three columns: department_id, department_name, percentage.
CREATE OR ALTER FUNCTION func4 (@dep_id NUMERIC(4))
RETURNS FLOAT
AS
BEGIN
    DECLARE @dep_emp_count NUMERIC;
    DECLARE @all_emp_count NUMERIC;

    SELECT @dep_emp_count = count(employee_id)
    FROM employees
    WHERE department_id = @dep_id;

    SELECT @all_emp_count = count(employee_id)
    FROM employees;

    RETURN CASE
           WHEN @all_emp_count = 0 THEN 0
           ELSE round(@dep_emp_count / @all_emp_count * 100, 2)
       END;
END;

SELECT department_id, department_name, dbo.func4(department_id) AS percentage
FROM departments;

-- 5. Create a func5 function that will return all information about departments located in the specified country. Call it
-- with the Canada parameter inside a query that produces two columns: department_id, department_name.
CREATE OR ALTER FUNCTION func5 (@country VARCHAR(40))
RETURNS TABLE
AS
RETURN (SELECT d.*
        FROM departments d
        JOIN locations l ON d.location_id = l.location_id
        JOIN countries c ON l.country_id = c.country_id
        WHERE c.country_name = @country);

SELECT department_id, department_name
FROM func5('Canada');