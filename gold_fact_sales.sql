USE ETL_PROJECT;
GO

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY sd.sls_ord_num, sd.sls_order_dt) AS sales_key,
    sd.sls_ord_num AS order_number,
    pr.product_key,      -- Surrogate key from dim_products
    cu.customer_key,     -- Surrogate key from dim_customers
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
    ON sd.sls_prd_key = pr.product_number  -- Join on business key
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;    
GO
