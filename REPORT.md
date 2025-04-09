# Performance Benchmark & Indexing Report


# Ecommerce Orders Performance Report
 **Date:** 2025-04-09
 **Author:** Priya Singh
## 1. Environment & Setup

- **MySQL Version**: 8.0.41 (Community Server)  
- **Deployment**: Docker Compose service `mysql_testing_ps-db`  
- **Database**: `ecommerce`  
- **Table**: `orders` (~29 033 rows loaded from `data/orders.csv`)  
- **Automation**:  
  - `provision.sh` handles schema import and CSV load  
  - Benchmarks executed in a Docker test runner (`mysql_test_runner`) sharing the MySQL container’s network
 
 ## 2. Baseline Benchmarks

Run inside the test runner:

```bash
**docker run --rm --network container:mysql_testing_ps-db-1 mysql_test_runner**
============================= test session starts ==============================
platform linux -- Python 3.9.21, pytest-8.3.5, pluggy-1.5.0
benchmark: 5.1.0 (defaults: timer=time.perf_counter disable_gc=False min_rounds=5 min_time=0.000005 max_time=1.0 calibration_precision=10 warmup=False warmup_iterations=100000)
rootdir: /tests
plugins: benchmark-5.1.0
collected 2 items

tests/test_fulltext.py .                                                 [ 50%]
tests/test_scalar.py .                                                   [100%]


----------------------------------------------------------------------------------- benchmark: 2 tests ----------------------------------------------------------------------------------
Name (time in ms)            Min                Max               Mean            StdDev             Median               IQR            Outliers       OPS            Rounds  Iterations
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
test_price_range          2.3513 (1.0)       9.2160 (1.0)       5.0547 (1.0)      1.5437 (1.0)       5.0734 (1.0)      2.2214 (1.08)         51;0  197.8359 (1.0)         155           1
test_fulltext_product     5.7948 (2.46)     16.6082 (1.80)     11.6061 (2.30)     2.3540 (1.52)     11.8418 (2.33)     2.0573 (1.0)          21;9   86.1618 (0.44)         69           1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Legend:
  Outliers: 1 Standard Deviation from Mean; 1.5 IQR (InterQuartile Range) from 1st Quartile and 3rd Quartile.
  OPS: Operations Per Second, computed as 1 / Mean
============================== 2 passed in 2.79s ===============================

2.1 Scalar Query: Price Range
"SELECT COUNT(*) FROM ecommerce.orders WHERE retail_price BETWEEN 50 AND 100;"
COUNT(*)
7189
2.2 Full‑Text Query: Name Search
SELECT product_id FROM orders WHERE MATCH(name) AGAINST('Cotton' IN NATURAL LANGUAGE MODE);
ft_count
1015

**3.  Extract Metrics: **docker run --rm --network container:mysql_testing_ps-db-1 mysql_test_runner | tee baseline.txt
============================= test session starts ==============================
platform linux -- Python 3.9.21, pytest-8.3.5, pluggy-1.5.0
benchmark: 5.1.0 (defaults: timer=time.perf_counter disable_gc=False min_rounds=5 min_time=0.000005 max_time=1.0 calibration_precision=10 warmup=False warmup_iterations=100000)
rootdir: /tests
plugins: benchmark-5.1.0
collected 2 items

tests/test_fulltext.py .                                                 [ 50%]
tests/test_scalar.py .                                                   [100%]


----------------------------------------------------------------------------------- benchmark: 2 tests ----------------------------------------------------------------------------------
Name (time in ms)            Min                Max               Mean            StdDev             Median               IQR            Outliers       OPS            Rounds  Iterations
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
test_price_range          2.5046 (1.0)       9.1973 (1.0)       5.6293 (1.0)      1.4895 (1.0)       5.8921 (1.0)      1.8570 (1.0)          32;0  177.6433 (1.0)         100           1
test_fulltext_product     5.5927 (2.23)     18.3160 (1.99)     10.4340 (1.85)     2.5898 (1.74)     10.9765 (1.86)     3.2488 (1.75)         22;3   95.8401 (0.54)         81           1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Legend:
  Outliers: 1 Standard Deviation from Mean; 1.5 IQR (InterQuartile Range) from 1st Quartile and 3rd Quartile.
  OPS: Operations Per Second, computed as 1 / Mean
============================== 2 passed in 2.58s ===============================

**4.Add Index & EXPLAIN**
Add the B‑tree index:EXPLAIN SELECT COUNT(*) FROM orders WHERE retail_price BETWEEN 50 AND 100\G" \

*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: orders
   partitions: NULL
         type: range
possible_keys: idx_retail_price
          key: idx_retail_price
      key_len: 6
          ref: NULL
         rows: 7189
     filtered: 100.00
        Extra: Using where; Using index
psingh21@Priya:/mnt/c/Users/singp/OneDrive/Desktop/DatabasesAutomation/MySql_testing_PS$ docker run --rm --network container:mysql_testing_ps-db-1 mysql_test_runner | tee indexed.txt
============================= test session starts ==============================
platform linux -- Python 3.9.21, pytest-8.3.5, pluggy-1.5.0
benchmark: 5.1.0 (defaults: timer=time.perf_counter disable_gc=False min_rounds=5 min_time=0.000005 max_time=1.0 calibration_precision=10 warmup=False warmup_iterations=100000)
rootdir: /tests
plugins: benchmark-5.1.0
collected 2 items

tests/test_fulltext.py .                                                 [ 50%]
tests/test_scalar.py .                                                   [100%]


----------------------------------------------------------------------------------- benchmark: 2 tests ----------------------------------------------------------------------------------
Name (time in ms)            Min                Max               Mean            StdDev             Median               IQR            Outliers       OPS            Rounds  Iterations
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
test_price_range          2.0330 (1.0)      11.7773 (1.0)       3.8582 (1.0)      1.7055 (1.0)       3.7328 (1.0)      1.7543 (1.0)          12;2  259.1853 (1.0)          57           1
test_fulltext_product     6.2000 (3.05)     17.4101 (1.48)     12.0617 (3.13)     2.1761 (1.28)     11.6923 (3.13)     1.9390 (1.11)         18;7   82.9071 (0.32)         61           1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Legend:
  Outliers: 1 Standard Deviation from Mean; 1.5 IQR (InterQuartile Range) from 1st Quartile and 3rd Quartile.
  OPS: Operations Per Second, computed as 1 / Mean
============================== 2 passed in 2.17s ===============================
**5. Post‑Index Benchmarks**
============================= test session starts ==============================
platform linux -- Python 3.9.21, pytest-8.3.5, pluggy-1.5.0
benchmark: 5.1.0 (defaults: timer=time.perf_counter disable_gc=False min_rounds=5 min_time=0.000005 max_time=1.0 calibration_precision=10 warmup=False warmup_iterations=100000)
rootdir: /tests
plugins: benchmark-5.1.0
collected 2 items

tests/test_fulltext.py .                                                 [ 50%]
tests/test_scalar.py .                                                   [100%]


---------------------------------------------------------------------------------- benchmark: 2 tests ---------------------------------------------------------------------------------
Name (time in ms)            Min                Max              Mean            StdDev            Median               IQR            Outliers       OPS          
  Rounds  Iterations
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
test_price_range          2.8524 (1.0)      18.9894 (1.12)     5.7944 (1.0)      1.9812 (1.0)      5.9348 (1.0)      1.9216 (1.0)          29;5  172.5816 (1.0)         117           1
test_fulltext_product     4.9918 (1.75)     16.9943 (1.0)      9.0980 (1.57)     3.3784 (1.71)     8.6239 (1.45)     6.4314 (3.35)         31;0  109.9140 (0.64)         63           1
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Legend:
  Outliers: 1 Standard Deviation from Mean; 1.5 IQR (InterQuartile Range) from 1st Quartile and 3rd Quartile.
  OPS: Operations Per Second, computed as 1 / Mean
============================== 2 passed in 2.46s ===============================

**6. Total Matches**
SELECT COUNT(*) AS ft_count \
FROM orders \
WHERE MATCH(name) AGAINST('Cotton' IN NATURAL LANGUAGE MODE);"
mysql: [Warning] Using a password on the command line interface can be insecure.
ft_count
1015



 
