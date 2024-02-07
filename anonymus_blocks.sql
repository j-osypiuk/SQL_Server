-- 1. For each employee, display their name, surname and commission information:
-- – "No commission" if the employee has no commission specified,
-- – "Unknown commission" in case the employee's commission cannot be compared to other employees in the same department,
-- – "Low commission" if the product of the commission and the minimum salary for the employee's position is less than the
-- average salary of all employees in this employee's department reduced by PLN 5,000,
-- – "High commission" in other cases.
-- Name the column with commission information commission_info. Sort the result by the last information. Use a conditional
-- statement in your solution.
SELECT e.first_name, e.last_name,
       CASE
           WHEN e.commission_pct IS NULL THEN 'No commission'
           WHEN (SELECT count(employee_id) FROM employees WHERE department_id = e.department_id) <= 1 THEN 'Unknown commission'
           WHEN e.commission_pct * j.min_salary < (SELECT avg(salary) FROM employees WHERE department_id = e.department_id) - 5000 THEN 'Low commission'
           ELSE 'High commission'
       END AS commission_info
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
ORDER BY commission_info;

-- 2. View country names, region names, and the number of departments located in each country. Limit the results depending
-- on the number of departments as follows:
-- – include only those countries from the Europe region that have more than 1 department,
-- – only include those countries in the Americas region that have more than 3 departments.
-- In the solution, use the CASE conditional statement in the HAVING clause.
SELECT c.country_name, r.region_name, count(d.department_id) AS departments_count
FROM countries c
JOIN locations l ON c.country_id = l.country_id
JOIN departments d ON l.location_id = d.location_id
JOIN regions r ON r.region_id = c.region_id
GROUP BY c.country_id, c.country_name, r.region_id, r.region_name
HAVING count(d.department_id) >
     CASE
         WHEN r.region_name = 'Europe' THEN 1
         WHEN r.region_name = 'Americas' THEN 3
     END;

-- 3. Analyze the following sequence of values and find the relationships:
--       5.
--       4.
--       4.1.
--       4.3.
--       4.4.
--       3.
--       3.1.
--       3.3.
--       2.
--       2.1.
--       1.
--       1.1.
-- Write an anonymous block that will print the above values. Use a LOOP and exit, continue and/or interrupt iteration
-- functions in your solution.
-- Attention! If a LOOP does not exist in a system, use another available type of loop.
BEGIN
    DECLARE @i INT = 4;
    DECLARE @j INT = 0;

    PRINT '5.';
    WHILE @i >= 1
    BEGIN
        WHILE @j <= @i
        BEGIN
            IF @j = 2
            BEGIN
                SET @j += 1;
                CONTINUE;
            END
            IF @j = 0
            BEGIN
                PRINT concat(@i, '.');
            END
            ELSE
            BEGIN
                PRINT concat(@i, '.', @j, '.');
            END
            SET @j += 1;
        END
        SET @j = 0;
        SET @i -= 1;
    END
END


-- 4. Create an anonymous block and declare appropriate variables in it. List the names of subsequent cities, starting
-- with the location with ID equal to 1500 and ending with the location with ID equal to 2500. Assume that the database
-- does not miss any location ID values in the above range, where the step is 100. For each city, write additionally
-- that many pairs of square brackets ([]), how many departments there are in it.
-- Attention! If your system allows it, use two types of loops in the solution: the FOR loop and the WHILE loop.
BEGIN
    DECLARE @city_info VARCHAR(100);
    DECLARE @departments_count INT;
    DECLARE @i INT = 1500;

    WHILE @i <= 2500
    BEGIN
        SELECT @city_info = city
        FROM locations
        WHERE location_id = @i;

        SELECT @departments_count = count(department_id)
        FROM departments
        WHERE location_id = @i;

        SET @city_info = @city_info + ' ';

        WHILE @departments_count > 0
        BEGIN
            SET @city_info = @city_info + '[]';
            SET @departments_count = @departments_count - 1;
        END

        PRINT @city_info;
        SET @i += 100;
    END
END

-- 5. Create an anonymous block and declare variables for the department name and city name in it. Display the name of the
-- department located in the selected city. Catch system exceptions by their names in cases where such a department does
-- not exist or there is more than 1 such department - write appropriate information. Try your solution for the cities of
-- Venice, Munich and Seattle.
-- Attention! If there are no system exceptions in a system for missing results or too many results, propose the simplest
-- solution possible to catch such errors.
BEGIN
    DECLARE @department_name VARCHAR(50);
    DECLARE @city_name VARCHAR(50) = 'Munich';
    DECLARE @departments_count INT;

    SELECT @departments_count = count(department_id)
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.city = @city_name;

    IF @departments_count = 0
    BEGIN
        PRINT @city_name + ' has not any departments.';
    END
    IF @departments_count > 1
    BEGIN
        PRINT @city_name + ' has more than one department.'
    END
    IF @departments_count = 1
    BEGIN
        SELECT @department_name = d.department_name
        FROM departments d
        JOIN locations l ON d.location_id = l.location_id
        WHERE l.city = @city_name

        PRINT @city_name + ' has ' + @department_name + ' department.';
    END
END


-- 6. Create an anonymous block and declare variables for the sum of salaries and the limit salary. Display the
-- total salaries of all employees. If this number is greater than the specified limit, just raise your exception and
-- print the appropriate information. Try your solution for the limit amounts of 500,000 and 700,000.
BEGIN
    DECLARE @salary_sum FLOAT;
    DECLARE @salary_limit FLOAT = 500000;

    SELECT @salary_sum = sum(salary)
    FROM employees;

    IF @salary_sum > @salary_limit
    BEGIN
        THROW 51000, 'Total salary of all employees is greater than specified limit.', 1;
    END

    PRINT concat('Total salary of all employees = $', @salary_sum);
END

-- 7. Create an anonymous block and declare appropriate variables and a cursor with a parameter referring to the country
-- name. List the location ID numbers and city names of the United States of America country whose name is sent to the cursor.
-- Attention! If a cursor with a parameter does not exist in some system, save the name of the given country in a variable
-- and use it in the cursor.
BEGIN
    DECLARE @country_name VARCHAR(100) = 'United States of America';
    DECLARE @location_id INT;
    DECLARE @city_name VARCHAR(100);
    DECLARE country_cities_cursor CURSOR
    FOR SELECT l.location_id, l.city
        FROM locations l
        JOIN countries c ON l.country_id = c.country_id
        WHERE c.country_name = @country_name;

    OPEN country_cities_cursor;
    FETCH NEXT FROM country_cities_cursor INTO @location_id, @city_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT concat('ID: ', @location_id, ', city: ', @city_name);
        FETCH NEXT FROM country_cities_cursor INTO @location_id, @city_name;
    END

    CLOSE country_cities_cursor;
    DEALLOCATE country_cities_cursor;
END

-- 8. Create an anonymous block and declare appropriate variables and cursor in it. Delete all locations where there is
-- no department. In your solution, use the WHERE CURRENT OF clause regarding the cursor.
BEGIN
    DECLARE @location_id INT;
    DECLARE locations_without_deps_cursor CURSOR
    FOR SELECT l.location_id
        FROM locations l
        WHERE l.location_id NOT IN (SELECT DISTINCT d.location_id
                                    FROM departments d
                                    WHERE d.location_id IS NOT NULL);

    OPEN locations_without_deps_cursor;
    FETCH NEXT FROM locations_without_deps_cursor INTO @location_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM locations
        WHERE CURRENT OF locations_without_deps_cursor;

        FETCH NEXT FROM locations_without_deps_cursor INTO @location_id;
    END

    CLOSE locations_without_deps_cursor;
    DEALLOCATE locations_without_deps_cursor;
END

-- 9. Create an anonymous block and declare appropriate variables in it. For each location, list all the data about it
-- along with the descriptions you added. The order of data in one message is: Location ID, ZIP Code, City, State/Province,
-- and Country. Please note that descriptions are not displayed if there are no values.
BEGIN
    DECLARE @location_data VARCHAR(255);
    DECLARE @location_id INT;
    DECLARE @postal_code VARCHAR(20), @city VARCHAR(50), @state_province VARCHAR(50), @country VARCHAR(50);
    DECLARE location_data_cursor CURSOR
    FOR SELECT l.location_id, l.postal_code, l.city, l.state_province, c.country_name
        FROM locations l
        JOIN countries c ON l.country_id = c.country_id;

    OPEN location_data_cursor;
    FETCH NEXT FROM location_data_cursor
    INTO @location_id, @postal_code, @city, @state_province, @country;

    WHILE @@fetch_status = 0
    BEGIN
        SET @location_data = @location_id;

        IF @postal_code IS NOT NULL
        BEGIN
            SET @location_data += ', ' + @postal_code;
        END
        IF @city IS NOT NULL
        BEGIN
            SET @location_data += ', ' + @city;
        END
        IF @state_province IS NOT NULL
        BEGIN
            SET @location_data += ', ' + @state_province;
        END
        IF @country IS NOT NULL
        BEGIN
            SET @location_data += ', ' + @country;
        END

        PRINT @location_data;

        FETCH NEXT FROM location_data_cursor
        INTO @location_id, @postal_code, @city, @state_province, @country;
    END

    CLOSE location_data_cursor;
    DEALLOCATE location_data_cursor;
END