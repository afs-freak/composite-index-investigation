# Composite Index Investigation

## 1. Objective

Investigate how the order of columns in a composite B-tree index affects query performance in PostgreSQL.

## 2. Test Environment

- Database: employee_reporting
- Table: employees
- Initial sample records: 8
- Benchmark records inserted: 200,000
- Total records tested: 200,008
- PostgreSQL version: 18.4

## 3. Incorrect Composite Index

The first experiment used:

```sql
CREATE INDEX idx_salary_department
ON employees (salary, department);
```

Test query:

```sql
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;
```

### Observed Results

- Query plan: Sequential Scan
- Actual rows returned: 14,000
- Rows removed by filter: 186,008
- Execution time: 16.641 ms
- Shared buffer hits: 2,000

PostgreSQL selected a Sequential Scan instead of using the incorrect composite index for this query.

## 4. Corrected Composite Index

The incorrect index was replaced with:

```sql
CREATE INDEX idx_department_salary
ON employees (department, salary);
```

The same query was executed again on the same dataset.

### Observed Results

- Query plan: Bitmap Heap Scan
- Index operation: Bitmap Index Scan
- Index used: idx_department_salary
- Actual rows returned: 14,000
- Execution time: 3.786 ms
- Shared buffer hits: 1,404
- Shared buffer reads: 57

PostgreSQL used both conditions in the index scan.

## 5. Performance Comparison

| Metric | Incorrect Index | Corrected Index |
|---|---:|---:|
| Index order | salary, department | department, salary |
| Query plan | Sequential Scan | Bitmap Heap Scan |
| Index scan | Not used | Bitmap Index Scan |
| Rows returned | 14,000 | 14,000 |
| Execution time | 16.641 ms | 3.786 ms |

The corrected index reduced execution time by approximately 77.2%, making the first query approximately 4.4 times faster in this test.

## 6. Second Query Test

The corrected index was also tested with:

```sql
SELECT *
FROM employees
WHERE department = 'Engineering'
AND salary >= 70000;
```

Observed results:

- Query plan: Bitmap Heap Scan
- Index operation: Bitmap Index Scan
- Index used: idx_department_salary
- Actual rows returned: 40,003
- Execution time: 6.452 ms

## 7. Explanation of the Fix

A composite B-tree index follows the Left-Most Prefix Rule. The order of indexed columns matters when designing an index for particular queries.

The original index placed salary before department. The corrected index places department first because the tested queries filter by department equality and then apply a salary range condition.

This column order allowed PostgreSQL to use both conditions in the index scan for the tested query.

## 8. Conclusion

The experiment demonstrated that composite index column order can significantly affect query execution plans and performance.

For the tested queries, the corrected index (department, salary) allowed PostgreSQL to use a Bitmap Index Scan and reduced the first query's execution time from 16.641 ms to 3.786 ms.