/*
===============================================================================
Quality Checks — Gold Layer (PostgreSQL)
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the star schema for analytical use cases.

Usage Notes:
    - Run after loading the Gold layer.
    - Expectation for checks marked "No results": the queries should return 0 rows.
    - Investigate and resolve any discrepancies found during the checks.

⚠️ WARNING
    Do not "fix" Gold directly unless your architecture explicitly allows it.
    Prefer fixing issues in Silver (or earlier) and rebuilding Gold.
===============================================================================
*/

-- ====================================================================
-- 1) Checking 'gold.dim_customers'
-- ====================================================================
-- Check for uniqueness of surrogate key in gold.dim_customers
-- Expectation: No results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- 2) Checking 'gold.dim_products'
-- ====================================================================
-- Check for uniqueness of surrogate key in gold.dim_products
-- Expectation: No results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- 3) Checking 'gold.fact_sales' connectivity
-- ====================================================================
-- Check referential integrity: every fact row should match existing dimension rows
-- Expectation: No results
SELECT
    f.order_number,
    f.customer_key,
    f.product_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;


-- ====================================================================
-- (Recommended) Extra checks for Gold quality
-- ====================================================================

-- A) Check for NULL surrogate keys in dimensions
-- Expectation: No results
SELECT customer_key
FROM gold.dim_customers
WHERE customer_key IS NULL;

SELECT product_key
FROM gold.dim_products
WHERE product_key IS NULL;


-- B) Check for NULL foreign keys in fact table
-- Expectation: No results (unless your design allows unknown keys)
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;
