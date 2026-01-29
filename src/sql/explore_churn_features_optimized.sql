-- Optimized Churn Features Exploration Script
-- This file contains performance-optimized queries for exploring the churn_user_features table
-- Performance improvements over original:
--   - Explicit column selection (reduces I/O)
--   - Added table statistics collection
--   - Query optimization commands
--   - Partition and Z-Order recommendations

-- ============================================================================
-- SECTION 1: Table Maintenance and Optimization
-- ============================================================================

-- 1.1: Collect statistics for better query planning (run periodically)
-- This helps the query optimizer make better decisions
ANALYZE TABLE demos.dbdemos_retail_c360.churn_user_features COMPUTE STATISTICS;

-- 1.2: Collect column-level statistics for commonly queried columns
-- Replace with actual column names from your table
ANALYZE TABLE demos.dbdemos_retail_c360.churn_user_features 
COMPUTE STATISTICS FOR COLUMNS 
    user_id, 
    churn_prediction, 
    churn_probability,
    last_activity_date;

-- 1.3: Optimize table to compact small files and improve read performance
-- Run this periodically (e.g., daily or weekly)
OPTIMIZE demos.dbdemos_retail_c360.churn_user_features;

-- 1.4: Z-Order by commonly filtered columns for faster queries
-- Adjust columns based on your query patterns
OPTIMIZE demos.dbdemos_retail_c360.churn_user_features
ZORDER BY (user_id, churn_prediction);

-- 1.5: Clean up old file versions (optional - keeps last 7 days by default)
-- Adjust retention period based on your requirements
-- VACUUM demos.dbdemos_retail_c360.churn_user_features RETAIN 168 HOURS;

-- ============================================================================
-- SECTION 2: Table Schema and Metadata
-- ============================================================================

-- 2.1: Describe the table schema
DESCRIBE TABLE demos.dbdemos_retail_c360.churn_user_features;

-- 2.2: Get detailed table information including partitions and statistics
DESCRIBE EXTENDED demos.dbdemos_retail_c360.churn_user_features;

-- 2.3: Show table properties and configuration
SHOW TBLPROPERTIES demos.dbdemos_retail_c360.churn_user_features;

-- 2.4: Get table history (Delta Lake time travel)
DESCRIBE HISTORY demos.dbdemos_retail_c360.churn_user_features
LIMIT 10;

-- ============================================================================
-- SECTION 3: Data Exploration Queries
-- ============================================================================

-- 3.1: Get sample data with explicit column selection
-- OPTIMIZED: Specifies only necessary columns instead of SELECT *
SELECT 
    user_id,
    churn_prediction,
    churn_probability,
    last_activity_date,
    total_purchases,
    platform
FROM demos.dbdemos_retail_c360.churn_user_features 
LIMIT 10;

-- 3.2: Get row count (efficient)
SELECT COUNT(*) as total_rows 
FROM demos.dbdemos_retail_c360.churn_user_features;

-- 3.3: Get row count by churn prediction
SELECT 
    churn_prediction,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM demos.dbdemos_retail_c360.churn_user_features
GROUP BY churn_prediction
ORDER BY churn_prediction;

-- 3.4: Distribution of churn probability (binned)
SELECT 
    CASE 
        WHEN churn_probability < 0.2 THEN 'Very Low (0-20%)'
        WHEN churn_probability < 0.4 THEN 'Low (20-40%)'
        WHEN churn_probability < 0.6 THEN 'Medium (40-60%)'
        WHEN churn_probability < 0.8 THEN 'High (60-80%)'
        ELSE 'Very High (80-100%)'
    END as churn_risk_category,
    COUNT(*) as user_count,
    ROUND(AVG(churn_probability) * 100, 2) as avg_probability_pct
FROM demos.dbdemos_retail_c360.churn_user_features
GROUP BY 
    CASE 
        WHEN churn_probability < 0.2 THEN 'Very Low (0-20%)'
        WHEN churn_probability < 0.4 THEN 'Low (20-40%)'
        WHEN churn_probability < 0.6 THEN 'Medium (40-60%)'
        WHEN churn_probability < 0.8 THEN 'High (60-80%)'
        ELSE 'Very High (80-100%)'
    END
ORDER BY churn_risk_category;

-- ============================================================================
-- SECTION 4: Advanced Analytics Queries
-- ============================================================================

-- 4.1: Summary statistics for numeric columns
SELECT 
    COUNT(*) as total_users,
    ROUND(AVG(churn_probability), 4) as avg_churn_probability,
    ROUND(STDDEV(churn_probability), 4) as stddev_churn_probability,
    MIN(churn_probability) as min_churn_probability,
    PERCENTILE(churn_probability, 0.25) as p25_churn_probability,
    PERCENTILE(churn_probability, 0.50) as median_churn_probability,
    PERCENTILE(churn_probability, 0.75) as p75_churn_probability,
    MAX(churn_probability) as max_churn_probability
FROM demos.dbdemos_retail_c360.churn_user_features;

-- 4.2: High-risk customers (churn probability > 70%)
-- OPTIMIZED: Uses WHERE clause for partition pruning if table is partitioned
SELECT 
    user_id,
    churn_probability,
    last_activity_date,
    total_purchases,
    DATEDIFF(CURRENT_DATE(), last_activity_date) as days_since_last_activity
FROM demos.dbdemos_retail_c360.churn_user_features
WHERE churn_probability > 0.7
ORDER BY churn_probability DESC
LIMIT 100;

-- 4.3: Customers at risk who were recently active
SELECT 
    user_id,
    churn_probability,
    last_activity_date,
    total_purchases
FROM demos.dbdemos_retail_c360.churn_user_features
WHERE churn_probability > 0.6
    AND last_activity_date >= DATE_SUB(CURRENT_DATE(), 30)
ORDER BY churn_probability DESC
LIMIT 50;

-- 4.4: Churn prediction accuracy check (if ground truth is available)
-- Uncomment and adjust if you have actual churn labels
/*
SELECT 
    churn_prediction as predicted_churn,
    actual_churned,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM demos.dbdemos_retail_c360.churn_user_features
GROUP BY churn_prediction, actual_churned
ORDER BY churn_prediction, actual_churned;
*/

-- ============================================================================
-- SECTION 5: Performance Monitoring
-- ============================================================================

-- 5.1: Check table size and file statistics
SELECT 
    size_in_bytes / 1024 / 1024 / 1024 as size_in_gb,
    num_files,
    size_in_bytes / NULLIF(num_files, 0) / 1024 / 1024 as avg_file_size_mb
FROM (
    DESCRIBE DETAIL demos.dbdemos_retail_c360.churn_user_features
);

-- 5.2: Identify if table has small files issue
-- If avg_file_size_mb < 128 MB, consider running OPTIMIZE
SELECT 
    CASE 
        WHEN (size_in_bytes / NULLIF(num_files, 0) / 1024 / 1024) < 128 
        THEN 'WARNING: Small files detected. Run OPTIMIZE command.'
        ELSE 'OK: File sizes are acceptable.'
    END as file_size_status,
    num_files,
    ROUND(size_in_bytes / NULLIF(num_files, 0) / 1024 / 1024, 2) as avg_file_size_mb
FROM (
    DESCRIBE DETAIL demos.dbdemos_retail_c360.churn_user_features
);

-- ============================================================================
-- SECTION 6: Data Quality Checks
-- ============================================================================

-- 6.1: Check for null values in critical columns
SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as null_user_id,
    SUM(CASE WHEN churn_prediction IS NULL THEN 1 ELSE 0 END) as null_churn_prediction,
    SUM(CASE WHEN churn_probability IS NULL THEN 1 ELSE 0 END) as null_churn_probability,
    SUM(CASE WHEN last_activity_date IS NULL THEN 1 ELSE 0 END) as null_last_activity_date
FROM demos.dbdemos_retail_c360.churn_user_features;

-- 6.2: Check for duplicate user_ids
SELECT 
    COUNT(*) as total_users,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(*) - COUNT(DISTINCT user_id) as duplicate_count
FROM demos.dbdemos_retail_c360.churn_user_features;

-- 6.3: Data freshness check
SELECT 
    MAX(last_activity_date) as most_recent_activity,
    MIN(last_activity_date) as earliest_activity,
    DATEDIFF(CURRENT_DATE(), MAX(last_activity_date)) as days_since_last_update
FROM demos.dbdemos_retail_c360.churn_user_features;

-- ============================================================================
-- NOTES:
-- ============================================================================
-- 1. Replace column names (user_id, churn_prediction, etc.) with actual columns
--    from your table schema
-- 2. Run OPTIMIZE command during off-peak hours
-- 3. Adjust VACUUM retention period based on your time-travel requirements
-- 4. Schedule statistics collection as part of your ETL pipeline
-- 5. Monitor query performance using Databricks Query History
-- ============================================================================
