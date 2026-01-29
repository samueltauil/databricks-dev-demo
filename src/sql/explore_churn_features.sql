-- Explore churn_user_features table in demos.dbdemos_retail_c360
-- PERFORMANCE OPTIMIZED VERSION

-- 1. Describe the table schema
DESCRIBE TABLE demos.dbdemos_retail_c360.churn_user_features;

-- 2. Get sample data (first 10 rows)
-- PERFORMANCE: Using explicit column selection instead of SELECT *
-- This reduces I/O and improves query performance
SELECT 
    user_id,
    churn_prediction,
    churn_probability,
    last_activity_date,
    total_purchases,
    platform
FROM demos.dbdemos_retail_c360.churn_user_features 
LIMIT 10;

-- 3. Get row count
SELECT COUNT(*) as total_rows FROM demos.dbdemos_retail_c360.churn_user_features;

-- 4. Get summary statistics for numeric columns
DESCRIBE EXTENDED demos.dbdemos_retail_c360.churn_user_features;

-- 5. PERFORMANCE OPTIMIZATION: Collect statistics for better query planning
-- Run this periodically to help the optimizer make better decisions
ANALYZE TABLE demos.dbdemos_retail_c360.churn_user_features COMPUTE STATISTICS;

-- 6. PERFORMANCE OPTIMIZATION: Optimize table to compact small files
-- Run this periodically (e.g., daily) to improve read performance
-- OPTIMIZE demos.dbdemos_retail_c360.churn_user_features;

-- NOTE: See explore_churn_features_optimized.sql for more comprehensive queries

