# Composite Index Investigation

## Overview

This project investigates how the order of columns in a composite B-tree index affects query performance in PostgreSQL.

The experiment compares an incorrect index order `(salary, department)` with the corrected index order `(department, salary)`.

## Database Setup

Create the database:

```sql
CREATE DATABASE employee_reporting;
```

Connect to it:

```sql
\c employee_reporting
```

Run these commands from the project root in PowerShell:

```powershell
psql -X -U postgres -v ON_ERROR_STOP=1 -d employee_reporting -f .\db\schema.sql

psql -X -U postgres -v ON_ERROR_STOP=1 -d employee_reporting -f .\db\sample_data.sql
```

## Experiment 1: Incorrect Index

Run:

```powershell
psql -X -U postgres -v ON_ERROR_STOP=1 -d employee_reporting -f .\db\01_incorrect_index.sql
```

This script:
- Inserts 200,000 benchmark records.
- Creates the incorrect composite index `(salary, department)`.
- Runs `EXPLAIN ANALYZE` on the test query.

## Experiment 2: Corrected Index

Run:

```powershell
psql -X -U postgres -v ON_ERROR_STOP=1 -d employee_reporting -f .\db\02_corrected_index.sql
```

This script:
- Removes the incorrect index.
- Creates the corrected composite index `(department, salary)`.
- Runs `ANALYZE`.
- Executes the same query and an additional test query using `EXPLAIN ANALYZE`.

## Main Test Query

```sql
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;
```

## Results

| Metric | Incorrect Index | Corrected Index |
|---|---:|---:|
| Index order | salary, department | department, salary |
| Query plan | Sequential Scan | Bitmap Heap Scan |
| Execution time | 16.641 ms | 3.786 ms |

The corrected index reduced execution time by approximately 77.2% in this experiment.

Detailed observations and performance comparisons are documented in [Changes.md](Changes.md).

## Project Structure

```text
composite-index-investigation/
├── db/
│   ├── schema.sql
│   ├── sample_data.sql
│   ├── queries.sql
│   ├── 01_incorrect_index.sql
│   └── 02_corrected_index.sql
├── Changes.md
└── README.md
```

## Tools Used

- PostgreSQL 18.4
- SQL
- EXPLAIN ANALYZE
- Composite B-tree Indexes