USE ETL_PROJECT;
GO

-- 1. REFERENTIAL INTEGRITY CHECK
-- Every prd_key in sales must exist in prd_info. Else FK broken
SELECT DISTINCT s.sls_prd_key
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p ON s.sls_prd_key = p.prd_key
WHERE p.prd_key IS NULL;
-- Expected: 0 rows. If >0 rows = orphan sales records

-- 2. DATE VALIDATION CHECK - Order Date
SELECT sls_ord_num, sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
   OR LEN(CAST(sls_order_dt AS VARCHAR(8))) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;
-- Expected: 0 rows after Silver ETL

-- 3. DATE VALIDATION CHECK - Ship Date  
SELECT sls_ord_num, sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
   OR LEN(CAST(sls_ship_dt AS VARCHAR(8))) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;

-- 4. DATE LOGIC CHECK
-- Order date cannot be after Ship/Due date
SELECT sls_ord_num, sls_order_dt, sls_ship_dt, sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt
   OR sls_ship_dt > sls_due_dt;
-- Expected: 0 rows = business logic clean

-- 5. SALES CALCULATION CONSISTENCY CHECK
-- Fix typo: sales_price → sls_price. Add missing END
SELECT DISTINCT
    sls_sales AS old_sales,
    sls_quantity,
    sls_price AS old_price,
    sls_quantity * ABS(sls_price) AS calc_sales,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 
             OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS fixed_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS fixed_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_sales <= 0
   OR sls_quantity IS NULL
   OR sls_quantity <= 0
   OR sls_price IS NULL
   OR sls_price <= 0;
-- This shows all rows your Silver ETL will fix
GO