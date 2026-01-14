# Performance Optimization Checklist

Use this checklist to ensure your Databricks notebooks and pipelines are optimized for performance.

## 📋 Pre-Deployment Checklist

### Data Loading and Ingestion
- [ ] **Auto Loader Configuration**
  - [ ] Set appropriate `maxFilesPerTrigger` based on file sizes
  - [ ] Enable schema inference with `cloudFiles.inferColumnTypes`
  - [ ] Configure schema evolution mode
  - [ ] Set checkpoint location for recovery

- [ ] **File Format Optimization**
  - [ ] Use Delta Lake format for all tables
  - [ ] Configure compression (Snappy for balanced, ZSTD for better compression)
  - [ ] Partition large tables by commonly filtered columns
  - [ ] Avoid over-partitioning (aim for files > 128MB)

### Query Optimization
- [ ] **Column Selection**
  - [ ] Replace `SELECT *` with explicit column names
  - [ ] Only select columns needed for the operation
  - [ ] Use column pruning in intermediate transformations

- [ ] **Predicate Pushdown**
  - [ ] Apply filters as early as possible
  - [ ] Use partition columns in WHERE clauses
  - [ ] Leverage Z-Order clustering for point lookups

- [ ] **Join Optimization**
  - [ ] Broadcast smaller tables (< 10MB) in joins
  - [ ] Use appropriate join types (inner, left, etc.)
  - [ ] Filter data before joining
  - [ ] Avoid cartesian products

### Table Maintenance
- [ ] **Statistics Collection**
  - [ ] Run `ANALYZE TABLE ... COMPUTE STATISTICS` regularly
  - [ ] Collect column-level statistics for filtered columns
  - [ ] Schedule statistics updates after major data loads

- [ ] **File Compaction**
  - [ ] Run `OPTIMIZE` daily or weekly
  - [ ] Use `ZORDER BY` for commonly filtered columns
  - [ ] Monitor file sizes with `DESCRIBE DETAIL`
  - [ ] Automate OPTIMIZE in production pipelines

- [ ] **Version Management**
  - [ ] Run `VACUUM` to remove old file versions
  - [ ] Set appropriate retention period (default: 7 days)
  - [ ] Balance time-travel needs with storage costs

### Code Quality
- [ ] **Memory Management**
  - [ ] Avoid `.collect()` on large datasets
  - [ ] Avoid `.toPandas()` unless necessary
  - [ ] Use `.write.saveAsTable()` for distributed operations
  - [ ] Implement `.cache()` with `.unpersist()` for reused DataFrames

- [ ] **Dependency Management**
  - [ ] Pin specific library versions
  - [ ] Use cluster libraries for production workloads
  - [ ] Avoid installing libraries in notebook cells
  - [ ] Consider Databricks Container Services for custom environments

- [ ] **Error Handling**
  - [ ] Implement try-except blocks for critical operations
  - [ ] Log errors with context information
  - [ ] Set up alerts for pipeline failures
  - [ ] Test error recovery scenarios

### ML Model Integration
- [ ] **Model Loading**
  - [ ] Cache model loading with broadcast variables
  - [ ] Use `pandas_udf` for distributed scoring
  - [ ] Batch predictions appropriately
  - [ ] Monitor model inference latency

- [ ] **Feature Engineering**
  - [ ] Precompute features where possible
  - [ ] Use window functions efficiently
  - [ ] Avoid UDFs when built-in functions are available
  - [ ] Test feature computation performance

## 🔍 Code Review Checklist

### SQL Queries
- [ ] No `SELECT *` statements in production code
- [ ] Explicit column selection in all queries
- [ ] Filters use partition columns when possible
- [ ] Statistics are collected on queried tables
- [ ] Complex queries use CTEs for readability

### PySpark Code
- [ ] No `.collect()` or `.toPandas()` on large datasets
- [ ] Appropriate use of `.cache()` with `.unpersist()`
- [ ] Built-in functions used instead of UDFs
- [ ] DataFrames are not unnecessarily materialized
- [ ] Broadcasting is used for small lookup tables

### Pipeline Configuration
- [ ] Auto-optimize enabled for Delta tables
- [ ] Partition strategy defined for large tables
- [ ] Data quality expectations are defined
- [ ] Pipeline mode (triggered vs. continuous) is appropriate
- [ ] Cluster configuration matches workload

## 📊 Performance Monitoring

### Metrics to Track
- [ ] **Pipeline Performance**
  - [ ] Processing time per batch
  - [ ] Records processed per second
  - [ ] Memory utilization
  - [ ] CPU utilization

- [ ] **Query Performance**
  - [ ] Query execution time
  - [ ] Data scanned per query
  - [ ] Query result caching hit rate
  - [ ] Photon acceleration metrics

- [ ] **Storage Metrics**
  - [ ] Table sizes and growth trends
  - [ ] Number of files per table
  - [ ] Average file size
  - [ ] Storage costs

- [ ] **Data Quality**
  - [ ] SDP expectation violations
  - [ ] Null value percentages
  - [ ] Duplicate record counts
  - [ ] Data freshness metrics

### Dashboards
- [ ] Create pipeline performance dashboard
- [ ] Monitor data quality metrics
- [ ] Track storage and compute costs
- [ ] Set up alerting for anomalies

## 🎯 Optimization Priorities

### High Impact (Do First)
1. ✅ Replace `SELECT *` with explicit columns
2. ✅ Run `OPTIMIZE` and `ZORDER` on large tables
3. ✅ Collect table statistics
4. ✅ Enable auto-optimize on Delta tables
5. ✅ Use partition pruning in queries

### Medium Impact (Do Next)
1. ⚡ Implement caching strategy for reused data
2. ⚡ Use pandas_udf for ML model scoring
3. ⚡ Schedule regular VACUUM operations
4. ⚡ Optimize cluster configuration
5. ⚡ Enable Photon acceleration

### Low Impact (Nice to Have)
1. 💡 Fine-tune Auto Loader settings
2. 💡 Implement advanced Z-Order strategies
3. 💡 Use materialized views for complex queries
4. 💡 Optimize join order in complex queries
5. 💡 Consider data skipping with bloom filters

## 🧪 Testing Checklist

### Before Deployment
- [ ] Run `EXPLAIN` on critical queries
- [ ] Benchmark query performance
- [ ] Test with production-scale data
- [ ] Validate data quality metrics
- [ ] Check cluster resource utilization
- [ ] Verify SLA compliance

### After Deployment
- [ ] Monitor pipeline execution
- [ ] Track query performance trends
- [ ] Review data quality dashboards
- [ ] Validate cost projections
- [ ] Gather user feedback
- [ ] Document lessons learned

## 📝 Documentation Checklist

- [ ] Pipeline architecture diagram created
- [ ] Data lineage documented
- [ ] Performance benchmarks recorded
- [ ] Maintenance procedures documented
- [ ] Troubleshooting guide created
- [ ] Code comments added for complex logic

## 🚨 Red Flags to Avoid

### Never Do This
- ❌ Use `.collect()` on tables with millions of rows
- ❌ Run production pipelines without error handling
- ❌ Skip table optimization for months
- ❌ Use `SELECT *` in production queries
- ❌ Ignore data quality failures
- ❌ Cache data without unpersisting
- ❌ Over-partition tables (> 10K partitions)
- ❌ Use cartesian products or cross joins
- ❌ Ignore performance monitoring
- ❌ Deploy without testing at scale

### Warning Signs
- ⚠️ Queries taking longer over time (missing statistics)
- ⚠️ Increasing storage costs (missing VACUUM)
- ⚠️ Many small files (missing OPTIMIZE)
- ⚠️ High memory usage (missing cache cleanup)
- ⚠️ Inconsistent runtimes (cluster autoscaling issues)

## ✅ Success Criteria

Your pipeline is well-optimized when:
- ✨ Queries complete within SLA targets
- ✨ Storage costs are predictable and controlled
- ✨ Data quality metrics are consistently high
- ✨ Pipeline failures are rare and recoverable
- ✨ Resource utilization is efficient (70-85%)
- ✨ End users are satisfied with performance

---

## 🔄 Review Frequency

- **Daily:** Monitor pipeline execution and failures
- **Weekly:** Review performance metrics and trends
- **Monthly:** Full performance audit and optimization
- **Quarterly:** Architecture review and capacity planning

## 📚 References

- [Databricks Performance Tuning Guide](https://docs.databricks.com/optimizations/index.html)
- [Delta Lake Best Practices](https://docs.databricks.com/delta/best-practices.html)
- [SDP Optimization](https://docs.databricks.com/workflows/delta-live-tables/delta-live-tables-optimization.html)
- [Query Optimization](https://docs.databricks.com/optimizations/sql.html)

---

**Last Updated:** 2026-01-14
**Version:** 1.0
