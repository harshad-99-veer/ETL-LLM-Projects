USE ETL_PROJECT
GO
PRINT('Truncating table silver.crm_cust_info')
TRUNCATE TABLE silver.crm_cust_info;
PRINT('insert the table silver.crm_cust_info')
INSERT INTO silver.crm_cust_info (
     cst_id,
     cst_key,
     cst_firstname,
     cst_lastname,
     cst_material_status,
     cst_gndr,
     cst_create_date)

SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'single'
     WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
     ELSE 'n/a'
END cst_material_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'm' THEN 'MALE'
     ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM(
SELECT 
*,
ROW_NUMBER() OVER(PARTITION  BY cst_id ORDER BY cst_create_date DESC) AS flag_list
FROM dbo.crm_cust_info
)t 
WHERE flag_list = 1 
