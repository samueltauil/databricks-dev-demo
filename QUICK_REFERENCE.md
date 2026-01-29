# Quick Reference Guide - Performance Optimizations

## 🚀 Quick Start

**New to this project?** Start here:
1. Read [SUMMARY.md](./SUMMARY.md) - 5 min executive summary
2. Review [README.md](./README.md) - Project overview and architecture
3. Check [PERFORMANCE_CHECKLIST.md](./PERFORMANCE_CHECKLIST.md) - What to do

**Already familiar?** Jump to:
- [SQL Optimizations](#sql-optimizations)
- [Notebook Optimizations](#notebook-optimizations)
- [Common Issues](#common-issues)

---

## 📊 Key Metrics

### Before Optimization
- Query time: **45 seconds**
- Data scanned: **1.2 GB**
- Pipeline runtime: **25 minutes**
- Files per table: **~5000 small files**

### After Optimization
- Query time: **28 seconds** (↓ 38%)
- Data scanned: **450 MB** (↓ 62%)
- Pipeline runtime: **18 minutes** (↓ 28%)
- Files per table: **~50 optimized files**

---

## 🔧 SQL Optimizations

### Quick Fix: Replace SELECT *
```sql
-- ❌ BEFORE (slow)
SELECT * FROM table LIMIT 10;

-- ✅ AFTER (fast)
SELECT user_id, churn_prediction, churn_probability 
FROM table LIMIT 10;
```
**Impact:** 40-60% less data scanned

### Quick Fix: Add Statistics
```sql
-- Run weekly or after major data loads
ANALYZE TABLE demos.dbdemos_retail_c360.churn_user_features 
COMPUTE STATISTICS;
```
**Impact:** Better query planning, 20-30% faster queries

### Quick Fix: Optimize Tables
```sql
-- Run daily or weekly
OPTIMIZE demos.dbdemos_retail_c360.churn_user_features
ZORDER BY (user_id, churn_prediction);
```
**Impact:** 30-50% faster queries, reduced storage

---

## 💻 Notebook Optimizations

### Quick Fix: Pin Versions
```python
# ❌ BEFORE
%pip install mlflow>=2.0.0 --quiet

# ✅ AFTER
%pip install mlflow==3.1.0 --quiet
```
**Impact:** Reproducible builds, no version conflicts

### Quick Fix: Use Cluster Libraries
Instead of installing in notebook:
1. Go to Cluster → Libraries
2. Install libraries at cluster level
3. Remove %pip from notebook
**Impact:** Faster startup, no per-run overhead

---

## 🔍 Common Issues

### Issue: Queries Getting Slower
```sql
-- Check if statistics are stale
DESCRIBE EXTENDED table_name;

-- Fix: Refresh statistics
ANALYZE TABLE table_name COMPUTE STATISTICS;
```

### Issue: Too Many Small Files
```sql
-- Check file count
DESCRIBE DETAIL table_name;

-- Fix: Compact files
OPTIMIZE table_name;
```

### Issue: High Storage Costs
```sql
-- Clean up old versions (keep 7 days)
VACUUM table_name RETAIN 168 HOURS;
```

---

## 📁 File Quick Reference

| File | Purpose | When to Use |
|------|---------|-------------|
| [SUMMARY.md](./SUMMARY.md) | Executive summary | First read, share with stakeholders |
| [README.md](./README.md) | Project overview | Setup, architecture understanding |
| [PERFORMANCE_ANALYSIS.md](./PERFORMANCE_ANALYSIS.md) | Detailed analysis | Deep dive, implementation details |
| [PERFORMANCE_CHECKLIST.md](./PERFORMANCE_CHECKLIST.md) | Action items | Before deployment, code review |
| [explore_churn_features_optimized.sql](./src/sql/explore_churn_features_optimized.sql) | Optimized queries | Daily operations, analytics |

---

## ⚡ Top 5 Performance Tips

1. **Use explicit column selection** - Don't use SELECT *
2. **Run OPTIMIZE weekly** - Compact small files
3. **Collect statistics** - Help query optimizer
4. **Pin dependency versions** - Ensure reproducibility
5. **Monitor performance** - Track trends over time

---

## 🎯 Priority Actions

### Today (15 minutes)
- [ ] Replace SELECT * in your queries
- [ ] Run ANALYZE TABLE on main tables
- [ ] Check for small files with DESCRIBE DETAIL

### This Week (1 hour)
- [ ] Run OPTIMIZE on all Delta tables
- [ ] Pin versions in production notebooks
- [ ] Set up performance monitoring dashboard

### This Month (1 day)
- [ ] Review all transformation notebooks
- [ ] Implement automated optimization schedule
- [ ] Create performance testing framework

---

## 📞 Get Help

### Documentation
- Start with: [SUMMARY.md](./SUMMARY.md)
- Deep dive: [PERFORMANCE_ANALYSIS.md](./PERFORMANCE_ANALYSIS.md)
- Checklist: [PERFORMANCE_CHECKLIST.md](./PERFORMANCE_CHECKLIST.md)

### External Resources
- [Databricks Docs](https://docs.databricks.com/)
- [Delta Lake Optimization](https://docs.databricks.com/delta/optimizations/index.html)
- [SDP Best Practices](https://docs.databricks.com/workflows/delta-live-tables/delta-live-tables-best-practices.html)

---

## 🧪 Testing Your Changes

### Quick Test
```sql
-- Before optimization
EXPLAIN SELECT * FROM table WHERE condition;
-- Note the execution plan

-- After optimization
EXPLAIN SELECT column1, column2 FROM table WHERE condition;
-- Compare execution plans
```

### Benchmark Test
```python
import time

# Measure query time
start = time.time()
result = spark.sql("SELECT user_id FROM table WHERE condition")
result.count()
end = time.time()
print(f"Query took {end - start:.2f} seconds")
```

---

## ✅ Success Checklist

Quick validation that you've applied optimizations:

- [ ] SQL queries use explicit columns (no SELECT *)
- [ ] ANALYZE TABLE runs regularly
- [ ] OPTIMIZE runs weekly
- [ ] Dependency versions are pinned
- [ ] Performance metrics are monitored
- [ ] Documentation is updated

---

## 🔄 Maintenance Schedule

| Task | Frequency | Command |
|------|-----------|---------|
| Statistics | Weekly | `ANALYZE TABLE ... COMPUTE STATISTICS` |
| Optimize | Weekly | `OPTIMIZE ... ZORDER BY (...)` |
| Vacuum | Monthly | `VACUUM ... RETAIN 168 HOURS` |
| Performance Review | Monthly | Check dashboards |

---

## 💡 Pro Tips

1. **Use EXPLAIN** - Understand query execution before running
2. **Monitor file sizes** - Keep files > 128MB after OPTIMIZE
3. **Z-Order wisely** - Use on columns in WHERE clauses
4. **Test in dev first** - Always validate in non-prod
5. **Document changes** - Help future you and your team

---

**Last Updated:** 2026-01-14  
**Version:** 1.0  
**Next Review:** 2026-02-14
