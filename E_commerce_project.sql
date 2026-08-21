
-- importing tables 

	CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

select * from customers 
limit 10 ;

-- Geolocation
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

select * from geolocation 
limit 10 ;


CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

select * from orders
limit 10 ;


-- Order Items
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT
);


select * from order_items
limit 10 ;

-- Order Reviews
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_creation_date VARCHAR(20),
    review_answer_timestamp VARCHAR(20)
);


select * from order_reviews
limit 10 ;


-- Products
CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght FLOAT,
    product_description_lenght FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

select * from products
limit 10 ;

-- Product Category Translation
CREATE TABLE product_category (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


select * from product_category
limit 10 ;


-- Sellers
CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

select * from sellers
limit 10 ;


SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'product_category', COUNT(*) FROM product_category
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers;

-- order status distribution 

SELECT order_status, COUNT(*) AS total_orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

select * from orders limit 30 ;

-- funnel analysis 

SELECT 
    COUNT(*) AS total_orders,
    COUNT(order_approved_at) AS approved,
    COUNT(order_delivered_carrier_date) AS shipped,
    COUNT(order_delivered_customer_date) AS delivered
FROM orders;

--jo orders approve ho gaye lekin kabhi ship hi nahi hue, unka status breakdown:

SELECT order_status, COUNT(*) AS stuck_orders
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NULL
GROUP BY order_status
ORDER BY stuck_orders DESC;

-- cancel order pattern

SELECT 
    CASE 
        WHEN order_approved_at IS NULL THEN 'Canceled before approval'
        WHEN order_delivered_carrier_date IS NULL THEN 'Canceled after approval, before shipping'
        WHEN order_delivered_customer_date IS NULL THEN 'Canceled after shipping, before delivery'
        ELSE 'Canceled after delivery (unusual)'
    END AS cancel_stage,
    COUNT(*) AS orders_count
FROM orders
WHERE order_status = 'canceled'
GROUP BY cancel_stage
ORDER BY orders_count DESC;


-- Category + Seller wise "failed" orders (unavailable + cancel-after-approval)

SELECT 
    pc.product_category_name_english AS category,
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS failed_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category pc 
    ON TRIM(LOWER(p.product_category_name)) = TRIM(LOWER(pc.product_category_name))
WHERE o.order_status = 'unavailable'
   OR (o.order_status = 'canceled' 
       AND o.order_approved_at IS NOT NULL 
       AND o.order_delivered_carrier_date IS NULL)
GROUP BY pc.product_category_name_english, oi.seller_id
ORDER BY failed_orders DESC
LIMIT 20;


