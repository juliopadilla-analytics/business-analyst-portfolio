# Benefits Enrollment Analysis with SQL

An end-to-end SQL project analyzing employee benefits enrollment and premium
contributions. Built as a companion to my
[Benefits Premium & Enrollment Power BI dashboard](https://github.com/juliopadilla-analytics/business-analyst-portfolio) —
same business domain, explored here with SQL instead of DAX.

> **Note:** the dataset is synthetic. All 60 employees, plan premiums, and
> enrollment records are fictional, generated to mirror the structure of
> real benefits enrollment data. The 85% employer contribution share reflects
> a scenario I modeled in a real workforce benefits analysis.

## Business questions answered

| # | Question | Key SQL skills |
|---|----------|----------------|
| 1 | Headcount vs. enrollment counts | `COUNT`, `COUNT(DISTINCT)`, scalar subqueries |
| 2 | Enrollments per benefit plan | `JOIN`, `GROUP BY`, `ORDER BY` |
| 3 | Monthly premium per plan, employer vs. employee split | `SUM`, arithmetic in `SELECT` |
| 4 | Overall employer/employee cost share | Percentage calculation, `ROUND` |
| 5 | Average premium by coverage tier | `AVG`, `GROUP BY` |
| 6 | Departments ranked by employer premium cost | Multiple `JOIN`s, `LIMIT` |
| 7 | Employees enrolled in more than one plan | `HAVING`, `GROUP_CONCAT` |
| 8 | Enrollments above the average employer cost | CTE (`WITH`) |
| 9 | Coverage tiers ranked by cost within each plan type | Window function `RANK() OVER (PARTITION BY ...)` |
| 10 | Month-over-month enrollment trend | `strftime`, grouping on derived values |

## Schema

- `departments` — department_id, department_name
- `employees` — employee_id, first/last name, department_id, hire_date
- `plans` — plan_id, plan_name (Health Plan A, Health Plan B, Dental, Vision), plan_type
- `enrollments` — enrollment_id, employee_id, plan_id, coverage_tier, employee_monthly, employer_monthly, enroll_date

## How to run

```bash
# Build the database (SQLite — no server needed)
sqlite3 benefits.db < schema.sql
sqlite3 benefits.db < seed_data.sql

# Run all ten queries
sqlite3 -header benefits.db < queries.sql
```

## Sample result — monthly premium by plan (Q3)

```
plan_name     | enrollments | employer_mo | employee_mo
Health Plan A | 20          | 19004.72    | 3353.79
Health Plan B | 26          | 16981.58    | 2996.76
Dental        | 22          | 1425.07     | 251.47
Vision        | 33          | 496.82      | 87.70
```

## What this demonstrates

Writing correct SQL against a realistic multi-table schema: joins across
four tables, aggregation with `GROUP BY`/`HAVING`, subqueries and CTEs, and
window functions — each query tied to a question a benefits analyst would
actually be asked.
