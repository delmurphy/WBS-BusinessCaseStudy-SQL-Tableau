#######################################
# Exploratory analysis of Magist data #
#######################################

USE magist;

-- 1. How many orders are there?
SELECT COUNT(DISTINCT(order_id)) FROM orders;
-- 99441
-- between which dates?
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) FROM orders;
# '2016-09-04 23:15:19' to '2018-10-17 19:30:18'


-- 2. How many orders were delivered?
SELECT 
    COUNT(DISTINCT (order_id)), order_status
FROM
    orders
GROUP BY order_status;
# 96478 delivered 

-- 3. Magist user growth?
SELECT 
    COUNT(DISTINCT (order_id)), YEAR(order_purchase_timestamp) AS y, MONTH(order_purchase_timestamp) AS m
FROM
    orders
GROUP BY y , m;
# yes (up until Sept 2018 - surprisingly few orders in Sept and Oct 2018)
# Jan 2017: 798 orders; Aug 2018: 6549 orders
# could be orders not entered in system yet? Are they manually entered, not automatic?

-- 4. How many products are there?
SELECT COUNT(*) FROM products;
# 32951

-- 5. Which categories have the most products?
SELECT 
    COUNT(*) AS n, t.product_category_name_english
FROM
    products AS p
        LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY n DESC;
# bed_bath_table (3029), sports_leisure, furniture_decor, health_beauty, housewares
# computer accessories in 7th place with 1639 
# telephony in 10th with 1134
# electronics has 517

-- 6. How many products were present in actual transactions?
SELECT COUNT(DISTINCT(product_id)) as n_distinct_products_ordered FROM order_items;
# every product listed has been ordered at least once

-- 7. What's the price of the most and least expensive products?
SELECT MAX(price) AS max_price, MIN(price) as min_price FROM order_items;
# max 6735, min 0.85
-- broken down per product category:
SELECT 
    MAX(o.price) AS max_price,
    MIN(o.price) AS min_price,
    t.product_category_name_english AS cat
FROM
    order_items AS o
        LEFT JOIN
    products AS p ON o.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY max_price DESC;
# for computer accessories, max = 3699.99, min = 3.90
# electronics max = 2470.50, min = 3.99
# telephony max = 2428, min = 5
# tablets_printing_image max = 889.99, min = 14.9

-- 8. What are the highest and lowest payment values?
SELECT MAX(payment_value) AS max_payment, MIN(payment_value) AS min_payment FROM order_payments;
# max 13664.10, min 0

-- investigate orders with 0 payment:
SELECT p.payment_type, o.order_status FROM order_payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE p.payment_value = 0;
# looks like payment is 0 when payment type is voucher, or when order is canceled

-- double check voucher payments being 0:
SELECT payment_type, payment_value FROM order_payments WHERE payment_type = "voucher";
# not all voucher payments are 0

-- what's being ordered when payment is 0?
SELECT t.product_category_name_english, op.payment_type FROM order_items oi
LEFT JOIN order_payments op ON op.order_id = oi.order_id
LEFT JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE op.payment_value = 0;
# no computer appliances, electronics etc. (closest is consoles_games)
