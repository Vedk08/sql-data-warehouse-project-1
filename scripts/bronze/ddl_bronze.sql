/*
===============================================================================
DDL Script: Create Bronze Tables (PostgreSQL)
===============================================================================

Script Purpose:
-------------------------------------------------------------------------------
This script creates the raw ingestion tables in the 'bronze' schema.

It is intended for PostgreSQL and will:
- Drop existing bronze tables if they already exist
- Recreate the bronze tables with a clean structure

When to run:
- First-time setup of the project database
- Any time you want to reset the Bronze DDL structure during development

Notes (PostgreSQL / DBeaver):
- PostgreSQL does NOT use `GO` batch separators.
- PostgreSQL does NOT support `IF OBJECT_ID(...)`.
  Instead we use: `DROP TABLE IF EXISTS ...`
- `NVARCHAR` is SQL Server-specific. In PostgreSQL use `TEXT` or `VARCHAR`.

⚠️ WARNING:
- Dropping tables will permanently delete all data in those tables.
- Run this only in development/portfolio environments unless you are sure.

===============================================================================
*/

-- Ensure the bronze schema exists
CREATE SCHEMA IF NOT EXISTS bronze;

-------------------------------------------------------------------------------
-- CRM: Customer Info
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id             INTEGER,
    cst_key            TEXT,
    cst_firstname      TEXT,
    cst_lastname       TEXT,
    cst_marital_status TEXT,
    cst_gndr           TEXT,
    cst_create_date    DATE
);

-------------------------------------------------------------------------------
-- CRM: Product Info
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id       INTEGER,
    prd_key      TEXT,
    prd_nm       TEXT,
    prd_cost     INTEGER,
    prd_line     TEXT,
    prd_start_dt TIMESTAMP,
    prd_end_dt   TIMESTAMP
);

-------------------------------------------------------------------------------
-- CRM: Sales Details
-- NOTE: order_dt / ship_dt / due_dt are stored as INT in the source in many
-- datasets (often in YYYYMMDD form). Keep them as INTEGER in BRONZE.
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  TEXT,
    sls_prd_key  TEXT,
    sls_cust_id  INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt  INTEGER,
    sls_due_dt   INTEGER,
    sls_sales    INTEGER,
    sls_quantity INTEGER,
    sls_price    INTEGER
);

-------------------------------------------------------------------------------
-- ERP: Location
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid   TEXT,
    cntry TEXT
);

-------------------------------------------------------------------------------
-- ERP: Customer
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid   TEXT,
    bdate DATE,
    gen   TEXT
);

-------------------------------------------------------------------------------
-- ERP: Product Category
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          TEXT,
    cat         TEXT,
    subcat      TEXT,
    maintenance TEXT
);

