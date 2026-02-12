/*
===============================================================================
Quality Checks (PostgreSQL)
===============================================================================
Run after loading the Silver Layer.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key IS NOT NULL
  AND cst_key <> TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
ORDER BY cst_marital_status;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm IS NOT NULL
  AND prd_nm <> TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
ORDER BY prd_line;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt IS NOT NULL
  AND prd_end_dt   IS NOT NULL
  AND prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- A) If you want to validate RAW bronze dates stored as YYYYMMDD (INT/TEXT),
--    use this. (Adjust column type casts depending on your bronze schema.)

-- Expectation: No Results
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt IS NULL
   OR LENGTH(TRIM(sls_due_dt::text)) <> 8
   OR sls_due_dt::text !~ '^[0-9]{8}$'
   OR sls_due_dt::int > 20500101
   OR sls_due_dt::int < 19000101;

-- Optional: also catch impossible dates like 20230230 (to_date would "normalize" it)
-- Expectation: No Results
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt IS NOT NULL
  AND LENGTH(TRIM(sls_due_dt::text)) = 8
  AND sls_due_dt::text ~ '^[0-9]{8}$'
  AND to_char(to_date(sls_due_dt::text, 'YYYYMMDD'), 'YYYYMMDD') <> sls_due_dt::text;

-- B) Silver table checks (dates are DATE already)

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT *
FROM silver.crm_sales_details
WHERE (sls_ship_dt IS NOT NULL AND sls_order_dt > sls_ship_dt)
   OR (sls_due_dt  IS NOT NULL AND sls_order_dt > sls_due_dt);

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales    IS NULL
   OR sls_quantity IS NULL
   OR sls_price    IS NULL
   OR sls_sales    <= 0
   OR sls_quantity <= 0
   OR sls_price    <= 0
   OR sls_sales <> (sls_quantity * sls_price)
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate IS NOT NULL
  AND (bdate < DATE '1924-01-01' OR bdate > CURRENT_DATE)
ORDER BY bdate;

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12
ORDER BY gen;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE (cat IS NOT NULL AND cat <> TRIM(cat))
   OR (subcat IS NOT NULL AND subcat <> TRIM(subcat))
   OR (maintenance IS NOT NULL AND maintenance <> TRIM(maintenance));

-- Data Standardization & Consistency
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2
ORDER BY maintenance;
