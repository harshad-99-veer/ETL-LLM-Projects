
USE ETL_PROJECT
GO

-- Products with no match in dimenstion products
SELECT 'Orphan Product' AS issue_type, f.sls_prd_key, COUNT(*) AS cnt
FROM silver.crm_sales_details f
LEFT JOIN gold.dim_products p ON f.sls_prd_key = p.product_number
WHERE p.product_key IS NULL
GROUP BY f.sls_prd_key;

-- Customers with no match in dimenstion customers  
SELECT 'Orphan Customer' AS issue_type, f.sls_cust_id, COUNT(*) AS cnt
FROM silver.crm_sales_details f
LEFT JOIN gold.dim_customers c ON f.sls_cust_id = c.customer_id
WHERE c.customer_key IS NULL
GROUP BY f.sls_cust_id;
GO

-- Duplicate product_number in dimenstion products
SELECT product_number, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Duplicate customer_id in dimenstion customers
SELECT customer_id, COUNT(*) AS cnt
FROM gold.dim_customers  
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO

-- Critical NULLs in dimenstion table view 
SELECT 'dim_customers' AS table_name, COUNT(*) AS null_gender
FROM gold.dim_customers WHERE gender IS NULL
UNION ALL
SELECT 'dim_products', COUNT(*) FROM gold.dim_products WHERE product_name IS NULL
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM gold.fact_sales WHERE sales_amount IS NULL;
GO

-- Negative sales/quantity/price
SELECT 'Negative Values' AS issue, sales_key, order_number, quantity, price, sales_amount
FROM gold.fact_sales
WHERE quantity < 0 OR price < 0 OR sales_amount < 0;

-- Future dates
SELECT 'Future Date' AS issue, sales_key, order_date
FROM gold.fact_sales
WHERE order_date > GETDATE();

-- Customer birth date in future
SELECT 'Invalid Birthdate' AS issue, customer_key, full_name, birth_date
FROM gold.dim_customers
WHERE birth_date > GETDATE();
GO
-- ROW count for all views
SELECT 
    (SELECT COUNT(*) FROM gold.dim_customers) AS dim_customers_rows,
    (SELECT COUNT(*) FROM gold.dim_products) AS dim_products_rows,
    (SELECT COUNT(*) FROM gold.fact_sales) AS fact_sales_rows,
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_sales_rows;
GO