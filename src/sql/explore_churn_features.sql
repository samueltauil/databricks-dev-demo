-- Explore churn_user_features table in demos.dbdemos_retail_c360

-- 1. Describe the table schema
DESCRIBE TABLE demos.dbdemos_retail_c360.churn_user_features;

-- 2. Get sample data (first 10 rows)
SELECT * FROM demos.dbdemos_retail_c360.churn_user_features LIMIT 10;

-- 3. Get row count
SELECT COUNT(*) as total_rows FROM demos.dbdemos_retail_c360.churn_user_features;

-- 4. Get summary statistics for numeric columns
DESCRIBE EXTENDED demos.dbdemos_retail_c360.churn_user_features;

