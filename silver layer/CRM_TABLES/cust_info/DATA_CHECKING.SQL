SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- cheack for unwanted spaces 
-- expecting result : no result

SELECT prd_nm
FROM silver.crm_prd_info
where prd_nm != TRIM(prd_nm)

-- cheack for NULL or Negative Numbers
-- expecting result : no result

SELECT prd_cost
FROM silver.crm_prd_info
where prd_cost < 0 OR prd_cost IS NULL

-- data standardization & consistency
SELECT DISTINCT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- Check cost cleaning worked
SELECT DISTINCT prd_cost FROM silver.crm_prd_info WHERE prd_cost = 0;

-- Check date conversion 
SELECT TOP 5 prd_start_dt, prd_end_dt FROM silver.crm_prd_info;

-- Check cat_id and prd_key split
SELECT TOP 5 cat_id, prd_key FROM silver.crm_prd_info;

--select all view
SELECT * FROM silver.crm_prd_info