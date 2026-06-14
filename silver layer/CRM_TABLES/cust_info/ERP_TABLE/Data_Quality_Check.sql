SELECT 
REPLACE(cid,'-','')cid,
cntry
FROM dbo.erp_loc_a101 
--check Other table cid Relative match 
WHERE REPLACE(cid,'-','') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

-- Data standardization & consistency
SELECT DISTINCT 
cntry AS OLD_cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM dbo.erp_loc_a101
ORDER BY cntry

-- check silver table qulity 
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry
--select all check
SELECT * FROM silver.erp_loc_a101
-- 4. POST-LOAD DQ CHECK
SELECT 'Total Rows' AS check_type, COUNT(*) AS cnt FROM silver.erp_loc_a101
UNION ALL
SELECT 'NULL CID', COUNT(*) FROM silver.erp_loc_a101 WHERE cid IS NULL
UNION ALL
SELECT 'Duplicate CID', COUNT(*) - COUNT(DISTINCT cid) FROM silver.erp_loc_a101
UNION ALL
SELECT 'CID still has dash', COUNT(*) FROM silver.erp_loc_a101 WHERE cid LIKE '%-%'
UNION ALL
SELECT 'FK Missing', COUNT(*) 
FROM silver.erp_loc_a101 l
LEFT JOIN silver.erp_cust_az12 c ON l.cid = c.cid
WHERE c.cid IS NULL;