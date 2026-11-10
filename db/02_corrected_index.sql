-- Experiment 2: Corrected composite index order
-- Equality-filter column first, range-filter column second.

-- Remove the incorrect index.
DROP INDEX IF EXISTS idx_salary_department;

-- Create the corrected composite index.
CREATE INDEX idx_department_salary
ON employees (department, salary);

-- Update PostgreSQL statistics.
ANALYZE employees;

-- Test the same query used in Experiment 1.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;

-- Test another query using the same index.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT *
FROM employees
WHERE department = 'Engineering'
AND salary >= 70000;
