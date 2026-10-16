-- ============================================================
-- Benefits Enrollment Analysis — schema
-- Synthetic dataset modeled on employee benefits enrollment data
-- ============================================================

CREATE TABLE departments (
    department_id   INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL
);

CREATE TABLE employees (
    employee_id   INTEGER PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    department_id INTEGER NOT NULL REFERENCES departments (department_id),
    hire_date     TEXT NOT NULL            -- ISO date: YYYY-MM-DD
);

CREATE TABLE plans (
    plan_id   INTEGER PRIMARY KEY,
    plan_name TEXT NOT NULL,               -- e.g. 'Health Plan A'
    plan_type TEXT NOT NULL                -- 'Health' | 'Dental' | 'Vision'
);

CREATE TABLE enrollments (
    enrollment_id   INTEGER PRIMARY KEY,
    employee_id     INTEGER NOT NULL REFERENCES employees (employee_id),
    plan_id         INTEGER NOT NULL REFERENCES plans (plan_id),
    coverage_tier   TEXT NOT NULL,         -- 'Employee Only' | 'Employee + Spouse'
                                          -- 'Employee + Children' | 'Family'
    employee_monthly REAL NOT NULL,       -- employee's share of monthly premium
    employer_monthly REAL NOT NULL,       -- employer's share of monthly premium
    enroll_date     TEXT NOT NULL          -- ISO date: YYYY-MM-DD
);
