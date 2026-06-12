SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--checked for unwanted spaces 
--exeptaion : no result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

--Data standrdization & conistancy
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

-- DELETE Dirty NULL FIRST ROW THEN COUNT ALL ROWS

USE ETL_PROJECT;
GO
DELETE FROM silver.crm_cust_info
WHERE cst_id IS NULL
  AND cst_key ='PO25';
GO
PRINT 'Dirty ROW DELETED .ROWCOUNT:'+ CAST(@@ROWCOUNT AS VARCHAR);

SELECT * FROM silver.crm_cust_info
