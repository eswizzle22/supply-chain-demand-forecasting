-- delete orders table if it exists to be able to re run queries
DROP TABLE IF EXISTS orders;

-- create table with columns matching the data set
CREATE TABLE orders (
    type                        VARCHAR(50),
    days_shipping_real          INT,
    days_shipping_scheduled     INT,
    benefit_per_order           DECIMAL(10,2),
    sales_per_customer          DECIMAL(10,2),
    delivery_status             VARCHAR(50),
    late_delivery_risk          INT,
    category_id                 INT,
    category_name               VARCHAR(100),
    customer_city               VARCHAR(100),
    customer_country            VARCHAR(100),
    customer_email              VARCHAR(150),
    customer_fname              VARCHAR(100),
    customer_id                 INT,
    customer_lname              VARCHAR(100),
    customer_password           VARCHAR(150),
    customer_segment            VARCHAR(50),
    customer_state              VARCHAR(100),
    customer_street             VARCHAR(150),
    customer_zipcode            VARCHAR(20),
    department_id               INT,
    department_name             VARCHAR(100),
    latitude                    DECIMAL(10,6),
    longitude                   DECIMAL(10,6),
    market                      VARCHAR(50),
    order_city                  VARCHAR(100),
    order_country               VARCHAR(100),
    order_customer_id           INT,
    order_date                  TIMESTAMP,
    order_id                    INT,
    order_item_cardprod_id      INT,
    order_item_discount         DECIMAL(10,2),
    order_item_discount_rate    DECIMAL(6,4),
    order_item_id               INT,
    order_item_product_price    DECIMAL(10,2),
    order_item_profit_ratio     DECIMAL(6,4),
    order_item_quantity         INT,
    sales                       DECIMAL(10,2),
    order_item_total            DECIMAL(10,2),
    order_profit_per_order      DECIMAL(10,2),
    order_region                VARCHAR(100),
    order_state                 VARCHAR(100),
    order_status                VARCHAR(50),
    order_zipcode               VARCHAR(20),
    product_card_id             INT,
    product_category_id         INT,
    product_description         TEXT,
    product_image               TEXT,
    product_name                VARCHAR(200),
    product_price               DECIMAL(10,2),
    product_status              INT,
    shipping_date               TIMESTAMP,
    shipping_mode               VARCHAR(50)
);

-- copy dataset into orders table
COPY orders FROM '/Users/ellasajor/__git/AI-driven-supply-chain/DataCoSupplyChainDataset.csv' 
DELIMITER ',' CSV HEADER ENCODING 'LATIN1';

-- validating the import 
SELECT COUNT(*) FROM orders; -- total number of rows for the dataset 
SELECT * FROM orders LIMIT 10; -- shows first 10 rows of data
SELECT MIN(order_date), MAX(order_date) FROM orders;  -- shows first to last order from 2015 to 2018
SELECT delivery_status, COUNT(*) 
FROM orders GROUP BY 1 ORDER BY 2 DESC; -- show number of each delivery status in descending order



