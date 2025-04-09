#!/usr/bin/env bash
set -euo pipefail

CONTAINER=mysql_testing_ps-db-1
HOST=127.0.0.1
PORT=3306

# 1. Load schema
docker cp schema.sql ${CONTAINER}:/schema.sql
docker exec ${CONTAINER} \
  mysql --protocol=TCP -h ${HOST} -P ${PORT} \
    -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "SOURCE /schema.sql;"

# 2. Get secure-file-priv directory
SECURE_DIR=$(docker exec ${CONTAINER} bash -c \
  "mysql --protocol=TCP -h ${HOST} -P ${PORT} \
    -u root -p\"${MYSQL_ROOT_PASSWORD}\" \
    -N -s -e \"SHOW VARIABLES LIKE 'secure_file_priv'\" | awk '{print \$2}'")

# 3. Copy CSV into that directory
docker cp data/orders.csv ${CONTAINER}:${SECURE_DIR}/orders.csv

# 4. Bulk import via server-side LOAD DATA INFILE
docker exec ${CONTAINER} \
  mysql --protocol=TCP -h ${HOST} -P ${PORT} \
    -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "USE ecommerce;
        LOAD DATA INFILE '${SECURE_DIR}orders.csv'
        INTO TABLE orders
        FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES;"

# 5. Create application user
docker exec ${CONTAINER} \
  mysql --protocol=TCP -h ${HOST} -P ${PORT} \
    -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ecommerce.* TO 'appuser'@'%';
        FLUSH PRIVILEGES;"

# 6. Verify
ROWCOUNT=$(docker exec ${CONTAINER} \
  mysql --protocol=TCP -h ${HOST} -P ${PORT} \
    -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -N -s -e "SELECT COUNT(*) FROM ecommerce.orders;")
echo "✅ Provisioning complete: imported ${ROWCOUNT} rows into ecommerce.orders."
