-- Experiment 1: Incorrect composite index order
-- The range-filter column (salary) comes before the equality-filter column (department).

-- Remove previous benchmark rows so this script can be rerun.
DELETE FROM employees
WHERE name LIKE 'Benchmark Employee %';

-- Generate benchmark data to make the query-plan comparison meaningful.
INSERT INTO employees (name, department, salary, hire_date)
SELECT
    'Benchmark Employee ' || n,
    CASE
        WHEN n % 10 = 0 THEN 'Sales'
        WHEN n % 10 BETWEEN 1 AND 5 THEN 'Engineering'
        WHEN n % 10 IN (6, 7) THEN 'HR'
        ELSE 'Marketing'
    END,
    30000 + (n % 70000),
    DATE '2020-01-01' + (n % 2000)
FROM generate_series(1, 200000) AS n;

-- Remove the corrected index before testing the incorrect order.
DROP INDEX IF EXISTS idx_department_salary;
DROP INDEX IF EXISTS idx_salary_department;

-- Incorrect order: range column first, equality column second.
CREATE INDEX idx_salary_department
ON employees (salary, department);

ANALYZE employees;

-- Observe the actual execution plan and timing.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;
