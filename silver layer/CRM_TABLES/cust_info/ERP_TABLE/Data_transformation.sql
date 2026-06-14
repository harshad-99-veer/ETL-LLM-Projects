/********************************************************************
* TABLE: silver.erp_loc_a101 
* PURPOSE: Cleaned ERP Location Data - Silver Layer
* RULES: 1.Remove '-' from CID 2.Standardize Country 3.Dedup 4.FK to cust
********************************************************************/

-- 1. DDL - DROP + CREATE
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(20) PRIMARY KEY,              -- Cleaned CID, no dashes
    cntry VARCHAR(50) NOT NULL DEFAULT 'n/a', -- Standardized Country Name
    
    -- Audit columns
    dwh_load_date DATETIME NOT NULL DEFAULT GETDATE(),
    dwh_source VARCHAR(50) NOT NULL DEFAULT 'erp_loc_a101',
    dwh_hash_key VARBINARY(32) NULL
);
GO

CREATE NONCLUSTERED INDEX IX_silver_erp_loc_a101_cid ON silver.erp_loc_a101(cid);
GO

-- 2. DATA TRANSFORMATION + INSERT USING MERGE
;WITH cleaned_data AS (
    SELECT 
        -- 2.1 CID Transformation: Remove all dashes
        REPLACE(cid, '-', '') AS clean_cid,
        
        -- 2.2 Country Transformation: Standardize codes to full names
        CASE 
            WHEN LTRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
            WHEN LTRIM(RTRIM(cntry)) IN ('US','USA') THEN 'United States'
            WHEN LTRIM(RTRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
            ELSE LTRIM(RTRIM(cntry))
        END AS clean_cntry,
        
        -- 2.3 Hash Key for change detection
        HASHBYTES('SHA2_256', 
            CONCAT(
                REPLACE(cid, '-', ''), '|',
                LTRIM(RTRIM(ISNULL(cntry, 'n/a')))
            )
        ) AS hash_key,
        
        -- 2.4 Deduplication: Keep 1 row per cleaned CID
        ROW_NUMBER() OVER(
            PARTITION BY REPLACE(cid, '-', '')
            ORDER BY REPLACE(cid, '-', '')  -- tie-breaker for dups
        ) AS rn
        
    FROM dbo.erp_loc_a101
    WHERE cid IS NOT NULL
)
-- 3. INSERT INTO silver.erp_loc_a101 using MERGE
MERGE silver.erp_loc_a101 AS target
USING (
    SELECT clean_cid, clean_cntry, hash_key
    FROM cleaned_data 
    WHERE rn = 1
    -- 3.1 FK Check: Only load if CID exists in silver.erp_cust_az12
    AND clean_cid IN (
        SELECT cid FROM silver.erp_cust_az12 WHERE cid IS NOT NULL
    )
) AS source
ON target.cid = source.clean_cid

WHEN MATCHED AND target.dwh_hash_key <> source.hash_key THEN
    UPDATE SET 
        cntry = source.clean_cntry,
        dwh_load_date = GETDATE(),
        dwh_hash_key = source.hash_key

WHEN NOT MATCHED BY TARGET THEN
    INSERT (cid, cntry, dwh_load_date, dwh_source, dwh_hash_key)
    VALUES (source.clean_cid, source.clean_cntry, GETDATE(), 'erp_loc_a101', source.hash_key);
GO


