/********************************************************************
* TABLE: silver.erp_px_cat_g1v2 
* PURPOSE: Cleaned ERP Product Category - Silver Layer
* RULES: 1.Trim spaces 2.Proper case 3.Maintenance Yes/No 4.Dedup
********************************************************************/

-- 1. DDL - DROP + CREATE
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(10) PRIMARY KEY,               -- Cleaned Product Category ID
    cat VARCHAR(50) NOT NULL,                 -- Category Name
    subcat VARCHAR(50) NOT NULL,              -- Subcategory Name  
    maintenance VARCHAR(3) NOT NULL DEFAULT 'No', -- Yes/No
    
    -- Audit columns
    dwh_load_date DATETIME NOT NULL DEFAULT GETDATE(),
    dwh_source VARCHAR(50) NOT NULL DEFAULT 'erp_px_cat_g1v2',
    dwh_hash_key VARBINARY(32) NULL
);
GO

CREATE NONCLUSTERED INDEX IX_silver_erp_px_cat_g1v2_id ON silver.erp_px_cat_g1v2(id);
GO

-- 2. DATA TRANSFORMATION + MERGE LOAD
;WITH cleaned_data AS (
    SELECT 
        -- 2.1 Clean ID: Remove spaces
        LTRIM(RTRIM(id)) AS clean_id,
        
        -- 2.2 Clean Category: Trim + Proper case
        UPPER(LEFT(LTRIM(RTRIM(cat)), 1)) + LOWER(SUBSTRING(LTRIM(RTRIM(cat)), 2, 50)) AS clean_cat,
        
        -- 2.3 Clean Subcategory: Trim + Proper case
        UPPER(LEFT(LTRIM(RTRIM(subcat)), 1)) + LOWER(SUBSTRING(LTRIM(RTRIM(subcat)), 2, 50)) AS clean_subcat,
        
        -- 2.4 Clean Maintenance: Standardize to Yes/No
        CASE 
            WHEN UPPER(LTRIM(RTRIM(maintenance))) IN ('Y','YES','1') THEN 'Yes'
            WHEN UPPER(LTRIM(RTRIM(maintenance))) IN ('N','NO','0','') OR maintenance IS NULL THEN 'No'
            ELSE 'No'
        END AS clean_maintenance,
        
        -- 2.5 Hash Key for SCD Type 1
        HASHBYTES('SHA2_256', 
            CONCAT(
                LTRIM(RTRIM(id)), '|',
                LTRIM(RTRIM(ISNULL(cat, ''))), '|',
                LTRIM(RTRIM(ISNULL(subcat, ''))), '|',
                LTRIM(RTRIM(ISNULL(maintenance, 'No')))
            )
        ) AS hash_key,
        
        -- 2.6 Dedup: 1 row per ID
        ROW_NUMBER() OVER(
            PARTITION BY LTRIM(RTRIM(id))
            ORDER BY LTRIM(RTRIM(id))
        ) AS rn
        
    FROM dbo.erp_px_cat_glv2  -- your Bronze table
    WHERE id IS NOT NULL
)
-- 3. MERGE INTO silver.erp_px_cat_g1v2
MERGE silver.erp_px_cat_g1v2 AS target
USING (
    SELECT clean_id, clean_cat, clean_subcat, clean_maintenance, hash_key
    FROM cleaned_data 
    WHERE rn = 1
) AS source
ON target.id = source.clean_id

WHEN MATCHED AND target.dwh_hash_key <> source.hash_key THEN
    UPDATE SET 
        cat = source.clean_cat,
        subcat = source.clean_subcat,
        maintenance = source.clean_maintenance,
        dwh_load_date = GETDATE(),
        dwh_hash_key = source.hash_key

WHEN NOT MATCHED BY TARGET THEN
    INSERT (id, cat, subcat, maintenance, dwh_load_date, dwh_source, dwh_hash_key)
    VALUES (source.clean_id, source.clean_cat, source.clean_subcat, source.clean_maintenance, GETDATE(), 'erp_px_cat_g1v2', source.hash_key);
GO
SELECT * FROM silver.erp_px_cat_glv2
