SELECT 
id,
cat,
subcat,
maintenance
FROM dbo.erp_px_cat_glv2

--check for unwanted spaces 
SELECT * FROM dbo.erp_px_cat_glv2
WHERE cat != TRIM(cat) OR subcat != TRIm(subcat) OR maintenance != TRIM(maintenance)

--Data standardization 
SELECT DISTINCT
maintenance
FROM dbo.erp_px_cat_glv2

-- 4. POST-LOAD DQ CHECKS
SELECT 'Total Rows' AS check_type, COUNT(*) AS cnt FROM silver.erp_px_cat_g1v2
UNION ALL
SELECT 'NULL ID', COUNT(*) FROM silver.erp_px_cat_g1v2 WHERE id IS NULL
UNION ALL
SELECT 'Duplicate ID', COUNT(*) - COUNT(DISTINCT id) FROM silver.erp_px_cat_g1v2
UNION ALL
SELECT 'Invalid Maintenance', COUNT(*) FROM silver.erp_px_cat_g1v2 WHERE maintenance NOT IN ('Yes','No')
UNION ALL
SELECT 'Empty Category', COUNT(*) FROM silver.erp_px_cat_g1v2 WHERE cat = '' OR cat IS NULL
UNION ALL

-- Select And check all 
SELECT * FROM silver.erp_px_cat_glv2
SELECT 'Spaces in ID', COUNT(*) FROM silver.erp_px_cat_g1v2 WHERE id <> LTRIM(RTRIM(id));
GO