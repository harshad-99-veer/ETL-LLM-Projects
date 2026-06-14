USE ETL_PROJECT;
GO 

IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
       sls_ord_num NVARCHAR(50),
       sls_prd_key NVARCHAR(50),
       sls_cust_id INT,
       sls_order_dt DATE,
       sls_ship_dt DATE,
       sls_due_dt DATE,
       sls_sales INT,
       sls_quantity INT,
       sls_price INT,
       dwh_create_date DATETIME DEFAULT GETDATE()
);
GO
PRINT('Truncating table silver.crm_sales_details')
TRUNCATE TABLE silver.crm_sales_details;
PRINT('insert the table silver.crm_sales_details')
INSERT INTO silver.crm_sales_details (
       sls_ord_num,
       sls_prd_key,
       sls_cust_id,
       sls_order_dt,
       sls_ship_dt,
       sls_due_dt,
       sls_sales,
       sls_quantity,
       sls_price,
       dwh_create_date  -- Added this column
)
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
         ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112)
    END AS sls_order_dt,
    
    CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
         ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112)
    END AS sls_ship_dt,
    
    CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
         ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)), 112)
    END AS sls_due_dt,
    
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,
    
    ABS(sls_quantity) AS sls_quantity,
    
    CASE WHEN sls_price IS NULL OR sls_price <= 0
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE ABS(sls_price)
    END AS sls_price,
    
    GETDATE() AS dwh_create_date  -- Match INSERT columns
    
FROM dbo.crm_sales_details;
GO
SELECT * FROM silver.crm_sales_details