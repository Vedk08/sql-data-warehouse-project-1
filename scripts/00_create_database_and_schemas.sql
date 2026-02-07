/* =============================================================================
   FILE: 00_create_database_and_schemas.sql
   PROJECT: Data Warehouse & Analytics (PostgreSQL)

   PURPOSE:
   ---------------------------------------------------------------------------
   This script is responsible for initializing the data warehouse environment.

   It performs the following actions:
   1. Creates the main data warehouse database: data_warehouse
      (if it does not already exist)
   2. Creates the three core schemas used in the Medallion Architecture:
      - bronze  : raw / ingested source data
      - silver  : cleaned and standardized data
      - gold    : business-ready, analytical data models

   This script should be executed BEFORE running any ETL or transformation logic.

   ---------------------------------------------------------------------------
   ⚠️  WARNING – DESTRUCTIVE OPERATIONS ⚠️
   ---------------------------------------------------------------------------
   - If you modify this script to DROP the database, ALL data will be lost.
   - Database-level operations cannot be rolled back.
   - Make sure you are connected to the correct PostgreSQL instance.
   - NEVER run destructive versions of this script in production.

   Intended for:
   - Local development
   - Learning environments
   - Portfolio projects

============================================================================= */

CREATE DATABASE data_warehouse;

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold');
