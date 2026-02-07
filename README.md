# sql-data-warehouse-project-1
Building a modern data warehouse with Postgres Sql Server, including ETL processes, data modelling, transformations and analytics.

---

## 🏗️ Data Architecture

This project follows the **Medallion Architecture** pattern with **Bronze**, **Silver**, and **Gold** layers:

### Bronze Layer
- Stores raw data exactly as received from source systems  
- Data is ingested from CSV files into PostgreSQL with no transformations  

### Silver Layer
- Cleansed and standardized data  
- Handles data quality issues such as missing values, duplicates, and inconsistent formats  

### Gold Layer
- Business-ready data modeled using a **star schema**  
- Optimized for analytical queries and reporting  

This layered approach improves **data quality, maintainability, and scalability**.

---

## 📖 Project Overview

This project covers the full lifecycle of a modern analytics system:

1. **Data Architecture Design**  
   - Designing a data warehouse using the Medallion Architecture  

2. **ETL Pipelines**  
   - Loading raw data into PostgreSQL  
   - Transforming data across Bronze → Silver → Gold layers  

3. **Data Modeling**  
   - Designing fact and dimension tables  
   - Implementing a star schema for analytics  

4. **Analytics & Reporting**  
   - Writing SQL queries to analyze customer behavior, product performance, and sales trends  

🎯 This project demonstrates skills relevant to:
- Data Engineering  
- Analytics Engineering  
- SQL Development  
- Data Modeling  
- Business Intelligence & Reporting  

---

## 🤖 Use of AI in This Project

Artificial Intelligence (AI) tools were **actively used throughout this project** to improve productivity and code quality.

AI was used to:
- Assist in writing SQL queries and transformations  
- Help debug SQL logic and resolve errors  
- Refactor queries for improved readability and performance  
- Validate data modeling decisions and architectural choices  

All AI-assisted code was:
- **Reviewed, tested, and modified manually**
- Adapted to the specific requirements of the project
- Fully understood and owned by the author  

This reflects a **modern, AI-augmented development workflow**, where AI is used as a productivity tool rather than a replacement for core data engineering skills.

---

## 🛠️ Tools & Technologies

All tools used in this project are **free and open-source**:

- **PostgreSQL** – Primary data warehouse database  
- **pgAdmin / DBeaver** – Database management and querying  
- **CSV Files** – Source data (ERP & CRM systems)  
- **Draw.io** – Architecture, data flow, and data model diagrams  
- **Git & GitHub** – Version control  
- **Notion** – Project planning and documentation  
- **AI-assisted development tools** – For coding, debugging, and optimization  

---

## 🚀 Project Requirements

### Data Warehouse (Data Engineering)

#### Objective
Build a modern data warehouse using **PostgreSQL** to consolidate sales data from multiple source systems and enable analytical reporting.

#### Specifications
- **Data Sources**  
  - ERP and CRM datasets provided as CSV files  

- **Data Quality**  
  - Clean and validate data before analysis  

- **Integration**  
  - Combine multiple sources into a unified analytical model  

- **Scope**  
  - Focus on the latest snapshot of data (no historization or SCD handling)  

- **Documentation**  
  - Provide clear documentation for data models and transformations  

---

### Analytics & Reporting

#### Objective
Develop SQL-based analytics to deliver insights into:
- Customer behavior  
- Product performance  
- Sales trends  

These insights can be used for dashboards and stakeholder reporting.

For more details, see `docs/requirements.md`.

---

## 📂 Repository Structure

data-warehouse-project/
│
├── datasets/ # Raw CSV datasets (ERP and CRM)
│
├── docs/ # Documentation and diagrams
│ ├── etl.drawio # ETL processes
│ ├── data_architecture.drawio # Medallion architecture diagram
│ ├── data_catalog.md # Dataset descriptions and metadata
│ ├── data_flow.drawio # Data flow diagram
│ ├── data_models.drawio # Star schema and data models
│ ├── naming-conventions.md # Naming standards
│
├── scripts/ # SQL scripts
│ ├── bronze/ # Raw data ingestion scripts
│ ├── silver/ # Data cleaning & transformation scripts
│ ├── gold/ # Analytical models (facts & dimensions)
│
├── tests/ # Data quality and validation scripts
│
├── README.md # Project overview
├── LICENSE # License information
├── .gitignore # Git ignore rules
└── requirements.txt # Project dependencies


---

## 🛡️ License

This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute this project with proper attribution.

---

## 🌟 About This Project

This project is a **hands-on learning and portfolio project**, inspired by real-world data engineering practices and implemented independently using **PostgreSQL**.

It emphasizes:
- Strong SQL fundamentals  
- Realistic data warehouse design  
- Clear documentation  
- Effective use of modern AI-assisted development tools  

---

