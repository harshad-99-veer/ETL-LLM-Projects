# ETL-LLM-Projects
I Want To Build My Resume Projects Repository For Data scientist Jobs 
# ETL Data Warehouse Project

3-layer Medallion Architecture for sales data.

**Bronze**: Raw CSV → SQL tables  
**Silver**: Data cleansing + standardization  
**Gold**: Star schema views for reporting

**Run order:**
1. bronze/ddl_bronze.sql
2. bronze/proc_load_bronze.sql  
3. silver/ddl_silver.sql
4. silver/proc_load_silver.sql
5. gold/ddl_gold_schema.sql
6. gold/*.sql
