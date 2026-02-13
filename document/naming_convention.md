# Naming Conventions – Data Warehouse Project

This document defines the naming conventions used across the **Bronze**, **Silver**, and **Gold** layers of the data warehouse. The goal is consistency, clarity, and long‑term maintainability while aligning with analytics and star‑schema best practices.

---

## 1. General Principles

* Use **snake_case** (lowercase letters with underscores).
* Use **English** for all object and column names.
* Avoid SQL **reserved keywords**.
* Names should be **descriptive, stable, and business‑meaningful**.
* Do not abbreviate unless the abbreviation is widely understood (e.g., `id`, `dt`).

---

## 2. Schema Naming

| Layer  | Purpose                               |
| ------ | ------------------------------------- |
| bronze | Raw, source‑faithful ingested data    |
| silver | Cleaned, standardized, validated data |
| gold   | Business‑ready analytical models      |

Schemas must always be referenced explicitly (e.g., `silver.crm_cust_info`).

---

## 3. Table Naming Conventions

### 3.1 Bronze Layer

* Represents **raw data exactly as received** from source systems.
* No renaming of entities or columns.
* Minimal transformations (type casting only if unavoidable).

**Pattern**
`<source_system>_<entity>`

**Examples**

* `crm_cust_info`
* `crm_sales_details`
* `erp_px_cat_g1v2`

---

### 3.2 Silver Layer

* Represents **cleaned and standardized** data.
* Table names remain aligned with the source system and entity.
* Business rules, data quality checks, and normalization are applied.

**Pattern**
`<source_system>_<entity>`

**Examples**

* `crm_cust_info`
* `crm_sales_details`
* `erp_cust_az12`

---

### 3.3 Gold Layer

* Represents **final analytical models** (Star Schema).
* Uses business‑aligned, descriptive names.
* No source‑system prefixes.

**Pattern**
`<category>_<entity>`

**Examples**

* `dim_customers`
* `dim_products`
* `fact_sales`

#### Category Prefix Glossary

| Prefix  | Meaning         | Example                |
| ------- | --------------- | ---------------------- |
| dim_    | Dimension table | `dim_customers`        |
| fact_   | Fact table      | `fact_sales`           |
| report_ | Reporting table | `report_sales_monthly` |

---

## 4. View Naming Conventions

* Views follow the **same naming rules as tables**.
* Gold views represent final analytical structures.
* Do **not** prefix views with `vw_`.

**Examples**

* `gold.dim_customers`
* `gold.fact_sales`

---

## 5. Column Naming Conventions

### 5.1 Surrogate Keys

* Surrogate keys must end with `_key`.

**Pattern**
`<entity>_key`

**Examples**

* `customer_key`
* `product_key`

---

### 5.2 Natural / Business Keys

* Retain original business identifiers from source systems.

**Examples**

* `customer_id`
* `product_number`
* `order_number`

---

### 5.3 Foreign Keys

* Foreign key column names must match the referenced surrogate key.

**Examples**

* `customer_key`
* `product_key`

---

### 5.4 Date Columns

* Date fields must end with `_date`.
* Timestamp fields must end with `_ts`.

**Examples**

* `order_date`
* `ship_date`
* `created_ts`

---

### 5.5 Boolean Columns

* Boolean columns must use clear, positive wording.

**Pattern**
`is_<condition>` or `has_<attribute>`

**Examples**

* `is_active`
* `has_maintenance`

---

### 5.6 Technical (Metadata) Columns

* All technical / system‑generated columns must start with `dwh_`.

**Pattern**
`dwh_<description>`

**Examples**

* `dwh_load_date`
* `dwh_source_system`
* `dwh_batch_id`

---

## 6. Stored Procedure Naming Conventions

* Stored procedures responsible for data loading must follow:

**Pattern**
`load_<layer>`

**Examples**

* `load_bronze`
* `load_silver`
* `load_gold`

---

## 7. Design Principles (Guiding Rules)

* Bronze = **faithful to source**
* Silver = **correct and standardized**
* Gold = **business‑friendly and analytical**

Constraints and surrogate keys are introduced **only in Gold** unless required earlier for data quality.

---

This convention ensures the data warehouse remains readable, scalable, and aligned with dimensional modeling best practices.
