USE ETL_PROJECT;
GO

-- STEP 1: Create gold schema if missing
-- Must be in its own batch, so we use EXEC for dynamic SQL
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold AUTHORIZATION dbo');
    PRINT 'Schema gold created successfully';
END
ELSE
    PRINT 'Schema gold already exists';
GO

-- STEP 2: Drop view if exists
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

-- STEP 3: Create the view
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    LTRIM(RTRIM(ci.cst_firstname)) AS first_name,
    LTRIM(RTRIM(ci.cst_lastname)) AS last_name,
    CONCAT(LTRIM(RTRIM(ci.cst_firstname)), ' ', LTRIM(RTRIM(ci.cst_lastname))) AS full_name,
    la.cntry AS country,
    ci.cst_material_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr 
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birth_date,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

