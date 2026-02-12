/*
===============================================================================
Procedure: Load Silver Layer (Bronze -> Silver)  [PostgreSQL]
===============================================================================
Purpose:
  Truncates Silver tables and inserts transformed/cleansed data from Bronze.

Usage:
  CALL silver.load_silver();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time      timestamptz;
    end_time        timestamptz;
    batch_start     timestamptz;
    batch_end       timestamptz;
BEGIN
    batch_start := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- ============================================================
    -- Loading silver.crm_cust_info
    -- ============================================================
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname)  AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)));
    RAISE NOTICE '>> -------------';


    -- ============================================================
    -- Loading silver.crm_prd_info
    -- ============================================================
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key FROM 1 FOR 5), '-', '_')             AS cat_id,
        SUBSTRING(prd_key FROM 7)                                     AS prd_key,
        prd_nm,
        COALESCE(NULLIF(TRIM(prd_cost::text), '')::int, 0)            AS prd_cost,
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END                                                           AS prd_line,
        prd_start_dt::date                                            AS prd_start_dt,
        ( LEAD(prd_start_dt::date) OVER (
              PARTITION BY SUBSTRING(prd_key FROM 7)
              ORDER BY prd_start_dt::date
          ) - INTERVAL '1 day'
        )::date                                                       AS prd_end_dt
    FROM bronze.crm_prd_info;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)));
    RAISE NOTICE '>> -------------';


    -- ============================================================
    -- Loading silver.crm_sales_details
    -- ============================================================
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price 
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt IS NULL THEN NULL
            WHEN sls_order_dt::bigint = 0 OR length(sls_order_dt::text) <> 8 THEN NULL
            ELSE to_date(sls_order_dt::text, 'YYYYMMDD')
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt IS NULL THEN NULL
            WHEN sls_ship_dt::bigint = 0 OR length(sls_ship_dt::text) <> 8 THEN NULL
            ELSE to_date(sls_ship_dt::text, 'YYYYMMDD')
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt IS NULL THEN NULL
            WHEN sls_due_dt::bigint = 0 OR length(sls_due_dt::text) <> 8 THEN NULL
            ELSE to_date(sls_due_dt::text, 'YYYYMMDD')
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> (sls_quantity * ABS(sls_price))
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
                THEN (sls_sales / NULLIF(sls_quantity, 0))
            ELSE sls_price
        END AS sls_price
    FROM bronze.crm_sales_details;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)));
    RAISE NOTICE '>> -------------';


    -- ============================================================
    -- Loading silver.erp_cust_az12
    -- ============================================================
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid FROM 4)
            ELSE cid
        END AS cid,
        CASE
            WHEN bdate > CURRENT_DATE THEN NULL
            ELSE bdate
        END AS bdate,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)));
    RAISE NOTICE '>> -------------';


    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    -- ============================================================
    -- Loading silver.erp_loc_a101
    -- ============================================================
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry
    FROM bronze.erp_loc_a101;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)));
    RAISE NOTICE '>> -------------';


    -- ============================================================
    -- Loading silver.erp_px_cat_g1v2
    -- ============================================================
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (end_time - start_time)));
    RAISE NOTICE '>> -------------';


    batch_end := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Silver Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', FLOOR(EXTRACT(EPOCH FROM (batch_end - batch_start)));
    RAISE NOTICE '==========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '==========================================';
        RAISE WARNING 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        RAISE WARNING 'SQLSTATE: %, Message: %', SQLSTATE, SQLERRM;
        RAISE WARNING '==========================================';
        -- Optionally: re-raise to fail the call
        -- RAISE;
END;
$$;
