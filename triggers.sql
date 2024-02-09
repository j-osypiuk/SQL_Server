-- 1. Create a trigger that checks if the hire date is a future date before adding the employee. If the condition
-- is not met, it will only display the message "Operation not allowed!". If the condition is met, it will add an employee.
-- Confirm the operation for two test cases.
CREATE OR ALTER TRIGGER on_employee_insert
ON employees
INSTEAD OF INSERT
AS
BEGIN
    IF (SELECT hire_date FROM inserted) > getdate()
    BEGIN
        THROW 51000, 'Operation not allowed!', 1;
    END;
    ELSE
    BEGIN
        INSERT INTO employees
        SELECT * FROM inserted;
    END;
END;

INSERT INTO employees(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary,  manager_id, department_id)
VALUES (9999, 'Alan', 'Davis', 'ala@mail.com', '143.353.4564', '2023-11-30', 'AD_PRES', 20000.00, 100, 90);

INSERT INTO employees(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary,  manager_id, department_id)
VALUES (9999, 'Alan', 'Davis', 'ala@mail.com', '143.353.4564', '2040-11-30', 'AD_PRES', 20000.00, 100, 90);

-- 2. Create a trigger that, when you remove multiple cities with a single command, displays their names and the names of
-- their countries. Confirm the action by removing all cities where no department is located.
CREATE OR ALTER TRIGGER on_city_delete
ON locations
AFTER DELETE
AS
BEGIN
    DECLARE @country VARCHAR(50);
    DECLARE @city VARCHAR(50);
    DECLARE cur CURSOR
    FOR SELECT c.country_name, d.city
        FROM deleted d
        JOIN countries c ON d.country_id = c.country_id;

    OPEN cur;
    FETCH NEXT FROM cur INTO @country, @city;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT concat(@city, ', ', @country);
        FETCH NEXT FROM cur INTO @country, @city;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;

DELETE FROM locations
WHERE location_id NOT IN (SELECT location_id
                          FROM departments
                          WHERE location_id IS NOT NULL);
