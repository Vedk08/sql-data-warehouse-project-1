# Data Catalog – Gold Layer

## Overview
The **Gold Layer** represents the business-facing data model of the data warehouse.  
It consists of **dimension tables** and **fact tables** designed to support analytical queries, reporting, and data marts.

All tables in this layer are:
- Cleaned and standardized
- Modeled using dimensional (star schema) principles
- Optimized for analytics and BI use cases

---

## 1. `gold.dim_customers`

### Purpose
Stores customer attributes enriched with demographic and geographic information.  
This table is used to analyze customer behavior and sales performance by customer-related dimensions.

### Columns

| Column Name       | Data Type        | Description |
|-------------------|------------------|-------------|
| customer_key      | INT              | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id       | INT              | Natural business identifier for the customer from the source system. |
| customer_number   | VARCHAR(50)      | Alphanumeric customer identifier used for tracking and referencing (e.g., CRM number). |
| first_name        | VARCHAR(50)      | Customer's first name after standardization and trimming. |
| last_name         | VARCHAR(50)      | Customer's last name after standardization and trimming. |
| country           | VARCHAR(50)      | Country of residence of the customer (e.g., 'Australia'). |
| marital_status    | VARCHAR(50)      | Marital status of the customer (e.g., 'Married', 'Single', 'Unknown'). |
| gender            | VARCHAR(20)      | Gender of the customer (e.g., 'Male', 'Female', 'Unknown'). |
| birthdate         | DATE             | Date of birth of the customer in `YYYY-MM-DD` format. |
| create_date       | DATE             | Date when the customer record was created in the source system. |

---

## 2. `gold.dim_products`

### Purpose
Provides descriptive information about products, including categorization, cost, and lifecycle attributes.  
This dimension enables analysis of sales performance by product characteristics.

### Columns

| Column Name            | Data Type        | Description |
|------------------------|------------------|-------------|
| product_key            | INT              | Surrogate key uniquely identifying each product record in the dimension table. |
| product_id             | INT              | Natural business identifier for the product from the source system. |
| product_number         | VARCHAR(50)      | Alphanumeric product code used for inventory tracking and categorization. |
| product_name           | VARCHAR(100)     | Descriptive name of the product, including key attributes (type, color, size). |
| category_id            | VARCHAR(50)      | Identifier representing the high-level product category. |
| category               | VARCHAR(50)      | High-level product category (e.g., Bikes, Components). |
| subcategory            | VARCHAR(50)      | More granular classification within the category (e.g., Mountain Bikes). |
| maintenance_required   | VARCHAR(10)      | Indicates whether maintenance is required (`Yes` / `No`). |
| cost                   | NUMERIC(10,2)    | Base cost of the product in monetary units. |
| product_line           | VARCHAR(50)      | Product line or series (e.g., Road, Mountain). |
| start_date             | DATE             | Date when the product became available for sale. |

---

## 3. `gold.fact_sales`

### Purpose
Stores transactional sales data at the order line level.  
This fact table is the core of the **Sales Data Mart**, enabling analysis of revenue, quantities, and trends over time.

### Columns

| Column Name      | Data Type        | Description |
|------------------|------------------|-------------|
| order_number     | VARCHAR(50)      | Unique alphanumeric identifier for each sales order (e.g., `SO54496`). |
| product_key      | INT              | Surrogate key referencing `gold.dim_products`. |
| customer_key     | INT              | Surrogate key referencing `gold.dim_customers`. |
| order_date       | DATE             | Date when the order was placed. |
| shipping_date    | DATE             | Date when the order was shipped to the customer. |
| due_date         | DATE             | Date when payment for the order was due. |
| sales_amount     | NUMERIC(10,2)    | Total monetary value of the sales line item. |
| quantity         | INT              | Number of product units sold in the line item. |
| price            | NUMERIC(10,2)    | Price per unit of the product at the time of sale. |

---

## Notes
- All surrogate keys are generated within the Gold layer.
- Fact tables reference dimension tables using surrogate keys only.
- Monetary values are stored using `NUMERIC` to ensure precision.
- This Gold layer serves as the foundation for reporting, dashboards, and downstream BI tools.
