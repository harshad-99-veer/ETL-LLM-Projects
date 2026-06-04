/*
==============================================================================================
Store Procedure : Load Bronze Layer (Sourse -> Bronze)
==============================================================================================
Script Purpose :
          This Store Prosedure Loads Data Into The 'bronze' Schema For External Csv Files ,
          It Perform The FolloWing Actions:
          -Truncating The Bronze Tables Before Loading data.
          -Inserting The Bulk 'Insert' Command To Load Data From The CSV Files To Bronze Tables.
Parameters :
         None 
      This Store Prosedure Does Not Accept Any Parameters OR Return Any Values.
Usage Example:
     EXEC dbo.load_dbo;
==============================================================================================
*/
USE ETL_PROJECT;
GO
CREATE OR ALTER PROCEDURE dbo.load_dbo AS
 BEGIN
     DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
     BEGIN TRY
         SET @batch_start_time = GETDATE();
         PRINT '========================';
         PRINT 'Loading a Bronze layer';
         PRINT '========================';
         PRINT '++++++++++++++++++++++++++++';
         PRINT 'Loading CRM Tables';
         PRINT '+++++++++++++++++++++++++++++';

         SET @start_time = GETDATE();
         PRINT 'Truncating Table : crm_cust_info';
        TRUNCATE TABLE crm_cust_info;
        PRINT 'Inserting  Table : crm_cust_info';
        BULK INSERT crm_cust_info
        FROM 'E:\Data_sets\cust_info.csv'
        WITH (
              FIRSTROW = 2,
              FIELDTERMINATOR = ',',
              TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> load Duration :' + cast(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
        PRINT '-------------------------------------';


        SET @start_time = GETDATE();
        PRINT 'Truncating Table : crm_prd_info';
        TRUNCATE TABLE crm_prd_info;
        PRINT 'Inserting Table : crm_prd_info';
        BULK INSERT crm_prd_info
        FROM 'E:\Data_sets\prd_info.csv'
        with(
              FIRSTROW = 2,
              FIELDTERMINATOR =',',
              TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>> load Duration :'+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+'second';
        print'---------------------------------------'

        SET @start_time = GETDATE();
        PRINT 'Truncating Table : crm_sales_details';
        TRUNCATE TABLE crm_sales_details;
        PRINT 'Inserting Table : crm_sales_details';
        BULK INSERT crm_sales_details
        FROM 'E:\Data_sets\sales_details.csv'
        WITH(
             FIRSTROW = 2,
             FIELDTERMINATOR =',',
             TABLOCK
        );
         SET @end_time = GETDATE();
        PRINT '>> load Duration :' + cast(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
        PRINT '-------------------------------------';

         PRINT '++++++++++++++++++++++++++++';
         PRINT 'Loading ERP Tables';
         PRINT '+++++++++++++++++++++++++++++';

        SET @start_time = GETDATE();
        PRINT 'Truncating Table :  erp_cust_az12';
        TRUNCATE TABLE erp_cust_az12;
        PRINT 'Inserting Table : erp_cust_az12';
        BULK INSERT erp_cust_az12
        FROM 'E:\Data_sets\CUST_AZ12.csv'
        WITH(
             FIRSTROW =2,
             FIELDTERMINATOR =',',
             TABLOCK
        );
         SET @end_time = GETDATE();
        PRINT '>> load Duration :' + cast(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
        PRINT '-------------------------------------';

        SET @start_time = GETDATE();
         PRINT 'Truncating Table : erp_loc_a101';
        TRUNCATE TABLE erp_loc_a101;
        PRINT 'Inserting Table : erp_loc_a101';
        BULK INSERT erp_loc_a101
        FROM 'E:\Data_sets\LOC_A101.csv'
        WITH(
             FIRSTROW =2,
             FIELDTERMINATOR =',',
             TABLOCK
        );
         SET @end_time = GETDATE();
        PRINT '>> load Duration :' + cast(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
        PRINT '-------------------------------------';

        SET @start_time = GETDATE();
        PRINT 'Truncating Table :erp_px_cat_glv2';
        TRUNCATE TABLE erp_px_cat_glv2;
        PRINT 'Inserting Table : erp_px_cat_glv2';
        BULK INSERT erp_px_cat_glv2
        FROM 'E:\Data_sets\PX_CAT_G1V2.csv'
        WITH(
             FIRSTROW =2,
             FIELDTERMINATOR =',',
             TABLOCK
        );
         SET @end_time = GETDATE();
        PRINT '>> load Duration :' + cast(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
        PRINT '-------------------------------------';

        SET @batch_end_time = GETDATE();
        PRINT'========================================================='
        PRINT'Loading Bronze Layer is Completed';
        PRINT'Total Load Duration :' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds';
    END TRY
    BEGIN CATCH
         PRINT '==========================';
         PRINT 'ERORR OCCURED BRONZE LAYER';
         PRINT 'Error Message : ' + ERROR_MESSAGE();
         PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
         PRINT 'Error State : ' + CAST(ERROR_STATE() AS NVARCHAR(10));
         PRINT 'Error Line : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
         PRINT '==================================================';
         THROW;  -- Added: sends error to caller so job fails properly
    END CATCH
 END
   GO
     EXEC dbo.load_dbo
