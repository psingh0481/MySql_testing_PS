CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  product_id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255),
  category VARCHAR(100),
  brand VARCHAR(100),
  department VARCHAR(100),
  cost DECIMAL(10,2),
  shipping_cost_1000_mile DECIMAL(10,2),
  retail_price DECIMAL(10,2),
  FULLTEXT KEY ft_name_desc (name)
) ENGINE=InnoDB;
