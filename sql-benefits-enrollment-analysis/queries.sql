-- ============================================================
-- Benefits Enrollment Analysis — business questions in SQL
-- Run against benefits.db (SQLite). Each query answers one
-- question a benefits analyst might actually be asked.
-- ============================================================

-- Q1. How many employees do we have, and how many plan
--     enrollments are on record?
-- Skills: COUNT, COUNT(DISTINCT)
SELECT
    (SELECT COUNT(*) FROM employees)              AS total_employees,
    (SELECT COUNT(*) FROM enrollments)            AS total_enrollments,
    (SELECT COUNT(DISTINCT employee_id)
     FROM enrollments)                            AS employees_enrolled;

-- Q2. How many enrollments does each benefit plan have?
-- Skills: JOIN, GROUP BY, ORDER BY
SELECT
    p.plan_name,
    p.plan_type,
    COUNT(*) AS enrollments
FROM enrollments e
JOIN plans p ON e.plan_id = p.plan_id
GROUP BY p.plan_name, p.plan_type
ORDER BY enrollments DESC;

-- Q3. What is the total monthly premium per plan, split into
--     employer cost vs. employee cost?
-- Skills: SUM, GROUP BY, arithmetic in SELECT
SELECT
    p.plan_name,
    COUNT(*)                                   AS enrollments,
    ROUND(SUM(e.employer_monthly), 2)          AS total_employer_monthly,
    ROUND(SUM(e.employee_monthly), 2)          AS total_employee_monthly,
    ROUND(SUM(e.employer_monthly + e.employee_monthly), 2) AS total_premium_monthly
FROM enrollments e
JOIN plans p ON e.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY total_premium_monthly DESC;

-- Q4. What share of total premium cost does the employer cover
--     vs. the employee?
-- Skills: SUM, percentage calculation, ROUND
SELECT
    ROUND(SUM(employer_monthly), 2) AS total_employer_monthly,
    ROUND(SUM(employee_monthly), 2) AS total_employee_monthly,
    ROUND(100.0 * SUM(employer_monthly)
          / SUM(employer_monthly + employee_monthly), 1) AS employer_share_pct,
    ROUND(100.0 * SUM(employee_monthly)
          / SUM(employer_monthly + employee_monthly), 1) AS employee_share_pct
FROM enrollments;

-- Q5. What is the average monthly premium by coverage tier?
-- Skills: AVG, GROUP BY
SELECT
    coverage_tier,
    COUNT(*) AS enrollments,
    ROUND(AVG(employer_monthly + employee_monthly), 2) AS avg_total_monthly,
    ROUND(AVG(employer_monthly), 2) AS avg_employer_monthly,
    ROUND(AVG(employee_monthly), 2) AS avg_employee_monthly
FROM enrollments
GROUP BY coverage_tier
ORDER BY avg_total_monthly DESC;

-- Q6. Which departments carry the highest total employer
--     premium cost?
-- Skills: two JOINs, GROUP BY, ORDER BY, LIMIT
SELECT
    d.department_name,
    COUNT(DISTINCT e.employee_id)              AS enrolled_employees,
    ROUND(SUM(en.employer_monthly), 2)         AS total_employer_monthly
FROM enrollments en
JOIN employees e   ON en.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_employer_monthly DESC;

-- Q7. Which employees are enrolled in more than one plan,
--     and which plans?
-- Skills: GROUP BY, HAVING, GROUP_CONCAT
SELECT
    e.first_name || ' ' || e.last_name AS employee,
    d.department_name,
    COUNT(*) AS plan_count,
    GROUP_CONCAT(p.plan_name, ', ') AS plans
FROM enrollments en
JOIN employees e   ON en.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
JOIN plans p       ON en.plan_id = p.plan_id
GROUP BY e.employee_id
HAVING COUNT(*) > 1
ORDER BY plan_count DESC, employee;

-- Q8. Which enrollments cost the employer more than the
--     average employer cost per enrollment?
-- Skills: CTE (WITH), scalar subquery, WHERE filter
WITH avg_cost AS (
    SELECT AVG(employer_monthly) AS avg_employer FROM enrollments
)
SELECT
    e.first_name || ' ' || e.last_name AS employee,
    p.plan_name,
    en.coverage_tier,
    en.employer_monthly,
    ROUND((SELECT avg_employer FROM avg_cost), 2) AS avg_employer_monthly
FROM enrollments en
JOIN employees e ON en.employee_id = e.employee_id
JOIN plans p     ON en.plan_id = p.plan_id
WHERE en.employer_monthly > (SELECT avg_employer FROM avg_cost)
ORDER BY en.employer_monthly DESC;

-- Q9. Rank coverage tiers by total premium within each plan
--     type (most expensive tier = rank 1).
-- Skills: window function RANK() OVER (PARTITION BY ... ORDER BY ...)
SELECT
    p.plan_type,
    en.coverage_tier,
    ROUND(SUM(en.employer_monthly + en.employee_monthly), 2) AS total_premium_monthly,
    RANK() OVER (
        PARTITION BY p.plan_type
        ORDER BY SUM(en.employer_monthly + en.employee_monthly) DESC
    ) AS tier_cost_rank
FROM enrollments en
JOIN plans p ON en.plan_id = p.plan_id
GROUP BY p.plan_type, en.coverage_tier
ORDER BY p.plan_type, tier_cost_rank;

-- Q10. How have enrollments trended month over month?
-- Skills: date function strftime, GROUP BY on derived value
SELECT
    strftime('%Y-%m', enroll_date) AS enroll_month,
    COUNT(*) AS new_enrollments,
    ROUND(SUM(employer_monthly + employee_monthly), 2) AS added_premium_monthly
FROM enrollments
GROUP BY enroll_month
ORDER BY enroll_month;
