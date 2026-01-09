###################################
# Magist Business Questions       #
###################################
-- Is Magist a good fit for high-end tech products, similar to what Eniac sells?
-- Are they reliable for deliveries?

USE magist;

############################
# In relation to the products
############################
-- 1. What categories of tech products does Magist have?
SELECT DISTINCT
    (product_category_name_english)
FROM
    product_category_name_translation;
# most similar to Eniac: 
# electronics, computers_accessories, tablets_printing_image, telephony, computers

-- 2. How many products in these categories have been sold? What percentage of total sales?
WITH total AS (SELECT COUNT(*) as grand_total FROM order_items)
SELECT COUNT(*) AS n_orders, 
ROUND((COUNT(*) * 100)/MAX(total.grand_total), 2) AS pct_of_total,
MAX(total.grand_total) AS total,
t.product_category_name_english FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
CROSS JOIN total
WHERE t.product_category_name_english IN 
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony")
GROUP BY t.product_category_name_english, total.grand_total;

-- without grouping (all tech together):
WITH total AS (SELECT COUNT(*) as grand_total FROM order_items)
SELECT COUNT(*) AS n_orders, MAX(total.grand_total) AS total,
ROUND((COUNT(*)*100/MAX(total.grand_total)), 2) AS pct_of_total 
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
CROSS JOIN total
WHERE t.product_category_name_english IN 
("electronics", "computers_accessories", 
"computers", "tablets_printing_image", "telephony");
# Tech products account for 13.69% (1,5425) of total sales

-- 3. average price of products sold (with each product contributing only 1 value to avg)
SELECT 
    ROUND(AVG(product_price), 2) AS avg_price
FROM
    (SELECT 
        product_id, MIN(price) AS product_price
    FROM
        order_items
    GROUP BY product_id) AS distinct_price;
# 143.53 (low compared with Eniac's avg item price: 540)

-- average price per category (with each product contributing only 1 value to avg)
WITH x AS 
(SELECT product_id, MIN(price) as product_price FROM order_items
GROUP BY product_id)
SELECT t.product_category_name_english, ROUND(AVG(x.product_price), 2) AS avg_product_price
FROM products p
LEFT JOIN product_category_name_translation t
ON t.product_category_name = p.product_category_name
LEFT JOIN x on x.product_id = p.product_id
WHERE t.product_category_name_english IN 
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony")
GROUP BY t.product_category_name_english;
# Note that average price for category 'computers' is much higher than the other tech categories
# computers: 1333.55; other tech categories range [82.51, 154.83]

-- 4. Are expensive tech products popular?
-- how do we define 'expensive'?
SELECT COUNT(*) as n_sold,
ROUND((COUNT(*)*100)/SUM(COUNT(*)) OVER(), 2) AS pct_of_tech_sales,
CASE WHEN oi.price > 1000 THEN ">1000"
WHEN oi.price > 800 THEN "800-1000"
WHEN oi.price > 600 THEN "600-800"
WHEN oi.price > 400 THEN "400-600"
WHEN oi.price > 200 THEN "200-400"
ELSE "0-200"
END AS price_cat
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN
("electronics", "computers_accessories", 
"computers", "tablets_printing_image", "telephony")
GROUP BY price_cat
ORDER BY price_cat;
# 91% of tech sales are for cheaper items (0-200€)

############################
# In relation to the sellers
############################
-- 5. How many months of data are there?
SELECT 
    COUNT(*) AS n_months
FROM
    (SELECT DISTINCT
        MONTH(order_purchase_timestamp) AS order_month,
            YEAR(order_purchase_timestamp) AS order_year
    FROM
        orders) AS month_counts;
# 25 months
        
 -- 6. How many sellers are there?   
SELECT 
    COUNT(DISTINCT seller_id) AS n_sellers
FROM
    sellers;
# 3095
-- How many Tech sellers are there?   
SELECT 
    COUNT(DISTINCT s.seller_id) AS n_tech_sellers
FROM
    sellers s
        LEFT JOIN
    order_items oi ON s.seller_id = oi.seller_id
        LEFT JOIN
    products p ON p.product_id = oi.product_id
        LEFT JOIN
    product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE
    t.product_category_name_english IN ('electronics' , 'computers_accessories',
        'computers',
        'tablets_printing_image',
        'telephony');
# 444
-- What percentage of overall sellers are Tech sellers?
SELECT COUNT(DISTINCT s.seller_id) AS n_sellers,
CASE WHEN t.product_category_name_english IN
("electronics", "computers_accessories", 
"computers", "tablets_printing_image", "telephony") 
THEN "tech_sellers"
ELSE "other"
END AS seller_type,
ROUND(COUNT(DISTINCT s.seller_id)*100/SUM(COUNT(DISTINCT s.seller_id)) OVER(), 2) as pct
FROM sellers s
LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t 
ON t.product_category_name = p.product_category_name
GROUP BY seller_type;
# 13.07% of all sellers are tech sellers (selling at least 1 tech item)

-- 7. What is the total amount earned by all sellers? 
SELECT 
    ROUND(SUM(payment_value), 2) AS total_payments
FROM
    order_payments;
# 16008872.14

-- What is the total amount earned by all Tech sellers? 
SELECT 
    ROUND(SUM(payment_value), 2) AS total_tech_payments
FROM
    order_payments op
        JOIN
    order_items oi ON oi.order_id = op.order_id
WHERE
    oi.seller_id IN (SELECT 
            oi.seller_id
        FROM
            order_items oi
                LEFT JOIN
            products p ON p.product_id = oi.product_id
                LEFT JOIN
            product_category_name_translation t ON t.product_category_name = p.product_category_name
        WHERE
            t.product_category_name_english IN ('electronics' , 'computers_accessories',
                'computers',
                'tablets_printing_image',
                'telephony'));
# 6166504.45

                
-- 8. average monthly income of all sellers? 
SELECT 
    ROUND(AVG(monthly_income), 2) AS avg_monthly_income
FROM
    (SELECT 
        oi.seller_id,
            YEAR(o.order_purchase_timestamp) AS yr,
            MONTH(o.order_purchase_timestamp) AS mn,
            SUM(op.payment_value) AS monthly_income
    FROM
        order_payments op
    JOIN orders o ON o.order_id = op.order_id
    JOIN order_items oi ON oi.order_id = op.order_id
    GROUP BY oi.seller_id , YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp)) seller_monthly_income;
# 1235.44

-- average monthly income of Tech sellers?
SELECT 
    ROUND(AVG(monthly_income), 2) AS avg_monthly_income
FROM
    (SELECT 
        oi.seller_id,
            YEAR(o.order_purchase_timestamp) AS yr,
            MONTH(o.order_purchase_timestamp) AS mn,
            SUM(op.payment_value) AS monthly_income
    FROM
        order_payments op
    JOIN orders o ON o.order_id = op.order_id
    JOIN order_items oi ON oi.order_id = op.order_id
    WHERE
        oi.seller_id IN (SELECT 
                oi.seller_id
            FROM
                order_items oi
            LEFT JOIN products p ON p.product_id = oi.product_id
            LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
            WHERE
                t.product_category_name_english IN ('electronics' , 'computers_accessories', 'computers', 'tablets_printing_image', 'telephony'))
    GROUP BY oi.seller_id , YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp)) seller_monthly_income;
# 1934.29


############################
# In relation to the delivery time
############################

-- how many orders were placed and how many were successfully delivered?
-- all orders
SELECT(COUNT(DISTINCT(order_id))) FROM orders;
# 99441
SELECT CASE
WHEN order_status = "delivered" THEN "delivered"
ELSE "other"
END AS delivery_status,
COUNT(DISTINCT(order_id)) AS n,
ROUND(COUNT(DISTINCT(order_id))*100/SUM(COUNT(DISTINCT(order_id))) OVER(), 2) AS pct
FROM orders
GROUP BY delivery_status;
# 96478 delivered (97%)

-- tech orders
SELECT(COUNT(DISTINCT(o.order_id))) FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony");
# 13684
SELECT CASE
WHEN o.order_status = "delivered" THEN "delivered"
ELSE "other"
END AS delivery_status,
COUNT(DISTINCT(o.order_id)) AS n,
ROUND(COUNT(DISTINCT(o.order_id))*100/SUM(COUNT(DISTINCT(o.order_id))) OVER(), 2) AS pct
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony")
GROUP BY delivery_status;
# 13382 delivered (98%)

-- 9. What’s the average time between the order being placed and the product being delivered?
-- all categories (national average)
SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date)) AS avg_delivery_time_days,
	STD(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date)) AS sd_delivery_time_days
FROM
    orders
WHERE
    order_delivered_customer_date IS NOT NULL
        AND order_purchase_timestamp IS NOT NULL;
# 12 days (sd = 9.55)
# good relative to Brazil's average in May 2020, 16 days for an online order delivery
# (source: https://www.statista.com/statistics/1117196/delivery-time-e-commerce-brazil/?srsltid=AfmBOopqkGjANMn_axJgpUI9RUO14lzVjm0DeIJQQ6QraFyiGIvBTu1x_
-- delivery time for all products broken down by region:
SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date)) AS avg_delivery_time_days,
	STD(TIMESTAMPDIFF(DAY,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date)) AS sd_delivery_time_days,
	g.state
FROM
    orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN geo g ON g.zip_code_prefix = c.customer_zip_code_prefix
WHERE
    o.order_delivered_customer_date IS NOT NULL
        AND o.order_purchase_timestamp IS NOT NULL
GROUP BY g.state
ORDER BY avg_delivery_time_days DESC;
# range 8.3 days (Sao Paulo) - 29 days (Roraima)

-- tech products delivery times (national average):
SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date)) AS delivery_time_days,
	STD(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date)) AS sd_delivery_time_days
FROM
    orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN 
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony");
#  12.6 days (sd = 9.22)

-- 10. How many orders are delivered on time vs orders delivered with a delay?
-- (relative to Magist's estimated delivery date)
-- all orders
SELECT COUNT(*) as n,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2) as pct,
CASE 
WHEN order_estimated_delivery_date < order_delivered_customer_date THEN "delayed"
ELSE "on time"
END AS delivery_time
FROM orders
WHERE order_status = "delivered"
GROUP BY delivery_time;
# 91.9% (88652) on time
-- tech orders
SELECT COUNT(*) as n,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2) as pct,
CASE 
WHEN o.order_estimated_delivery_date < o.order_delivered_customer_date THEN "delayed"
ELSE "on time"
END AS delivery_time
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN 
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony")
AND o.order_status = "delivered"
GROUP BY delivery_time;
# 91.7% (13,837) on time

-- How late are the delayed deliveries?
-- (relative to Magist's estimated delivery date)
-- all orders
SELECT COUNT(*) as n,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2) as pct,
CASE 
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 1 
THEN "1 day"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 2 
THEN "2 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 3 
THEN "3 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 4 
THEN "4 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 5 
THEN "5 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) >= 6 
THEN "6+ days"
ELSE "on time"
END AS delay_time
FROM orders
WHERE order_status = "delivered"
GROUP BY delay_time
HAVING delay_time <> "on time"
ORDER BY delay_time;
# 57.6% of delayed orders are delayed by more than 6 days

-- tech orders
-- (delays relative to Magist's estimated delivery date)
SELECT COUNT(*) as n,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2) as pct,
CASE 
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 1 
THEN "1 day"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 2 
THEN "2 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 3 
THEN "3 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 4 
THEN "4 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) = 5 
THEN "5 days"
WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) >= 6 
THEN "6+ days"
ELSE "on time"
END AS delay_time
FROM orders o
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
    WHERE oi.order_id = o.order_id
      AND t.product_category_name_english IN
      ("electronics", "computers_accessories",
	"computers", "tablets_printing_image", "telephony")
)
AND order_status = "delivered"
GROUP BY delay_time
HAVING delay_time <> "on time"
ORDER BY delay_time;
# 54.5% of delayed orders are delayed by more than 6 days

-- How many deliveries are made more than 12 days (national average delivery time) after order ?
SELECT COUNT(*) as n,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2) as pct,
CASE 
WHEN TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) > 12 THEN "delayed"
ELSE "on time"
END AS delivery_time
FROM orders
WHERE order_status = "delivered"
GROUP BY delivery_time;
# 35.9% take more than 12 days


-- what's the average expected delivery time?
-- all orders
SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_estimated_delivery_date)), 2)
AS avg_expected_delivery_time_days,
ROUND(STD(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_estimated_delivery_date)), 2)
AS sd_expected_delivery_time_days
FROM orders;
# mean = 23.4 (sd = 8.8)
-- all orders by region
SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date)), 2)
AS avg_expected_delivery_time_days,
ROUND(STD(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date)), 2)
AS sd_expected_delivery_time_days,
g.state
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN geo g ON g.zip_code_prefix = c.customer_zip_code_prefix
GROUP BY g.state
ORDER BY avg_expected_delivery_time_days DESC;
# ranges from 18.8 days in Sao Paulo to 46.2 days in Roraima (northernmost, geographically isolated area)

-- tech orders (national average)
SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date)), 2)
AS avg_expected_delivery_time_days,
ROUND(STD(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date)), 2)
AS sd_expected_delivery_time_days
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony");
# mean: 23.9
# sd: 8.3

-- what's the average actual delivery time?
-- all orders
SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2)
AS avg_delivery_time_days,
ROUND(STD(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2)
AS sd_delivery_time_days
FROM orders;
# mean = 12.1 (sd = 9.55)
-- all orders by region
SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, order_delivered_customer_date)), 2)
AS avg_expected_delivery_time_days,
ROUND(STD(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, order_delivered_customer_date)), 2)
AS sd_expected_delivery_time_days,
g.state
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN geo g ON g.zip_code_prefix = c.customer_zip_code_prefix
GROUP BY g.state
ORDER BY avg_expected_delivery_time_days DESC;
# ranges from 8.3 days in Sao Paulo to 29 days in Roraima (northernmost, geographically isolated area)

-- 11. Is there any pattern for delayed orders, e.g. big products being delayed more often?
-- get size of items in each order:
WITH x AS
(SELECT oi.order_id,
SUM(p.product_length_cm * p.product_height_cm * p.product_width_cm) AS volume
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
GROUP BY oi.order_id)
-- add delays
SELECT
CASE 
WHEN order_estimated_delivery_date < order_delivered_customer_date THEN "delayed"
ELSE "on time"
END AS delay,
AVG(x.volume) AS avg_volume
FROM orders o
JOIN x ON x.order_id = o.order_id
WHERE o.order_status = "delivered"
GROUP BY delay;
-- avg volume on time = 17229.8 cm^3
-- avg volume delayed = 18488.4 cm^3

-- get size of items in each order:
WITH x AS
(SELECT oi.order_id,
SUM(p.product_length_cm * p.product_height_cm * p.product_width_cm) AS volume
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony")
GROUP BY oi.order_id)
-- add delays
SELECT
CASE 
WHEN order_estimated_delivery_date < order_delivered_customer_date THEN "delayed"
ELSE "on time"
END AS delay,
AVG(x.volume) AS avg_volume
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
JOIN x ON x.order_id = o.order_id
WHERE t.product_category_name_english IN
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony")
AND o.order_status = "delivered"
GROUP BY delay;
-- avg volume on time = 7044.13 cm^3
-- avg volume delayed = 11077.74 cm^3

-- what about heavier packages?
WITH x AS
(SELECT oi.order_id,
SUM(p.product_weight_g) AS weight
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
GROUP BY oi.order_id)
-- add delays
SELECT
CASE 
WHEN order_estimated_delivery_date < order_delivered_customer_date THEN "delayed"
ELSE "on time"
END AS delay,
AVG(x.weight) AS avg_weight
FROM orders o
JOIN x ON x.order_id = o.order_id
WHERE o.order_status = "delivered"
GROUP BY delay;
# on time: 2363.6g
# delayed: 2651.8g

-- look at delays with more resolution on package size:
-- get size of items in each order:
WITH x AS
(SELECT oi.order_id,
SUM(p.product_length_cm * p.product_height_cm * p.product_width_cm) AS volume
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
GROUP BY oi.order_id),
-- add delays
y AS 
(SELECT
CASE 
WHEN o.order_estimated_delivery_date < o.order_delivered_customer_date THEN "delayed"
ELSE "on time"
END AS delay,
CASE
WHEN x.volume <= 5000 THEN "0-5k"
WHEN x.volume <= 10000 THEN "5-10k"
WHEN x.volume <= 15000 THEN "10-15k"
WHEN x.volume <= 15000 THEN "15-20k"
ELSE "20k+"
END AS size_cat
FROM orders o
JOIN x ON x.order_id = o.order_id
WHERE o.order_status = "delivered")
SELECT size_cat, delay, COUNT(*) AS n,
ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY size_cat),
        2
    ) AS pct
FROM y
GROUP BY size_cat, delay
ORDER BY size_cat, delay;
#No real pattern - each size category has about 7.5 - 8.5% delayed packages

-- how are the customer ratings?
SELECT COUNT(DISTINCT(order_id)) FROM order_reviews;
# 98371 reviews for 98279 orders - some orders have multiple reviews
SELECT AVG(review_score) FROM order_reviews; 
# 4.1
-- how about just for orders including a tech product?
SELECT AVG(review_score) FROM order_reviews orv
LEFT JOIN order_items oi ON oi.order_id = orv.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name_english IN 
("electronics", "computers_accessories",
"computers", "tablets_printing_image", "telephony");
# 3.95

SELECT MIN(review_score), MAX(review_score) FROM order_reviews;
# 1 - 5