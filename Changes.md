# Document your index fixes here

- Original index: `CREATE INDEX idx_salary_department ON employees(salary, department);`
- Issue observed: The original index was ordered by `salary` first, then `department`. The query filters on `department = 'Sales'` (equality) and `salary > 50000` (range). Because of the Left-Most Prefix Rule, putting the range condition column first makes the index inefficient. The database engine has to scan many index entries or fall back to a Sequential Scan.
- Fixed index: `CREATE INDEX idx_department_salary ON employees(department, salary);`
- Performance improvement: By placing the equality condition column (`department`) first, followed by the range condition column (`salary`), the database can immediately jump to the 'Sales' department entries in the index and then efficiently scan the relevant salaries. This allows the query planner to utilize an Index Scan effectively.
