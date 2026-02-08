/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
-------------------------------------------------------------------------------
This stored procedure loads raw source data into the 'bronze' schema of the
data warehouse from external CSV files.

It follows a truncate-and-reload strategy and performs the following actions:
- Truncates existing data from all bronze tables.
- Loads fresh data from CSV files using PostgreSQL's COPY command.
- Logs execution progress and load durations for observability.
- Captures and reports errors during execution.

This procedure represents the initial ingestion step in the Medallion
Architecture (Bronze → Silver → Gold).

-------------------------------------------------------------------------------
⚠️  WARNING – DESTRUCTIVE OPERATION
-------------------------------------------------------------------------------
- This procedure TRUNCATES all bronze tables before loading data.
- All existing data in the bronze layer will be permanently deleted.
- Database-level COPY operations cannot be rolled back.
- Ensure CSV file paths are correct and accessible by the PostgreSQL server.
- Intended for local development, learning, and portfolio environments only.
- DO NOT run destructive procedures like this in production systems.

-------------------------------------------------------------------------------
Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

-------------------------------------------------------------------------------
Usage Example:
    CALL bronze.load_bronze();

===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_start_time timestamptz := clock_timestamp();
    batch_end_time   timestamptz;
    step_start_time  timestamptz;
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    ---------------------------------------------------------------------------
    -- CRM TABLES
    ---------------------------------------------------------------------------
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- crm_cust_info
    step_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM '/Users/ved/Downloads/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM clock_timestamp() - step_start_time);
    RAISE NOTICE '>> -------------';

    -- crm_prd_info
    step_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM '/Users/ved/Downloads/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM clock_timestamp() - step_start_time);
    RAISE NOTICE '>> -------------';

    -- crm_sales_details
    step_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM '/Users/ved/Downloads/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM clock_timestamp() - step_start_time);
    RAISE NOTICE '>> -------------';

    ---------------------------------------------------------------------------
    -- ERP TABLES
    ---------------------------------------------------------------------------
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    -- erp_loc_a101
    step_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101
    FROM '/Users/ved/Downloads/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM clock_timestamp() - step_start_time);
    RAISE NOTICE '>> -------------';

    -- erp_cust_az12
    step_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12
    FROM '/Users/ved/Downloads/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM clock_timestamp() - step_start_time);
    RAISE NOTICE '>> -------------';

    -- erp_px_cat_g1v2
    step_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2
    FROM '/Users/ved/Downloads/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM clock_timestamp() - step_start_time);
    RAISE NOTICE '>> -------------';

    ---------------------------------------------------------------------------
    -- COMPLETION
    ---------------------------------------------------------------------------
    batch_end_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer Completed Successfully';
    RAISE NOTICE '   - Total Load Duration: % seconds',
        EXTRACT(EPOCH FROM batch_end_time - batch_start_time);
    RAISE NOTICE '================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE '================================================';
        RAISE;
END;
$$;

