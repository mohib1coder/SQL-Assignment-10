-- Question 1: Aggregate functions on order_items
SELECT 
    COUNT(*) AS total_lines,
    SUM(quantity) as total_units,
    AVG(list_price) as avg_price,
    MIN(list_price) as min_price,
    MAX(list_price) as max_price
FROM sales.order_items;


-- Question 2: Count tests
-- Part a
SELECT COUNT(*) FROM sales.customers;

-- Part b
SELECT COUNT(email) as email_count, COUNT(phone) as phone_count 
FROM sales.customers;

-- Part c
SELECT COUNT(*)
FROM sales.customers
WHERE phone IS NULL;



-- Question 3: Group By basics
-- Part a
SELECT product_id
	,SUM(quantity) AS total_sold
FROM sales.order_items
GROUP BY product_id
ORDER BY total_sold DESC;


-- Part b
SELECT state, COUNT(*) as total_customers
FROM sales.customers
GROUP BY state
ORDER BY total_customers DESC;

-- Part c
SELECT staff_id, order_status, COUNT(*) as cnt
FROM sales.orders
GROUP BY staff_id, order_status;


-- Question 4: Group By with Joins
-- Part a
SELECT c.category_name, ROUND(AVG(p.list_price), 2) as average_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

-- Part b
SELECT b.brand_name, COUNT(p.product_id) as prod_count
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY prod_count DESC;

-- Part c
SELECT c.customer_id, c.first_name, c.last_name, 
       COUNT(DISTINCT o.order_id) as total_orders,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as money_spent
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;


-- Question 5: Having clause
-- Part a
SELECT model_year, COUNT(*) as count_prod
FROM production.products
GROUP BY model_year
HAVING COUNT(*) > 50;

-- Part b
SELECT customer_id, COUNT(*) as ord_cnt
FROM sales.orders
GROUP BY customer_id
HAVING COUNT(*) >= 2;

-- Part c
SELECT product_id, SUM(quantity) as total_qty
FROM sales.order_items
GROUP BY product_id
HAVING SUM(quantity) > 100;

-- Part d: WHERE filtering se pehle rows par lagta hai jabke HAVING grouping ke baad groups par condition lagata hai.


-- Question 6: Where + Group By + Having
SELECT o.store_id, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = 2017
GROUP BY o.store_id
HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 100000
ORDER BY revenue DESC;


-- Question 7: Subquery in WHERE (IN)
-- Part a
SELECT * FROM sales.orders
WHERE customer_id IN (SELECT customer_id FROM sales.customers WHERE city = 'New York');

-- Part b
SELECT product_id, product_name FROM production.products
WHERE category_id IN (SELECT category_id FROM production.categories WHERE category_name IN ('Electric Bikes', 'Cruisers Bicycles'));

-- Part c
SELECT first_name, last_name, city FROM sales.customers
WHERE customer_id IN (SELECT customer_id FROM sales.orders);


-- Question 8: Scalar & NOT IN Subqueries
-- Part a
SELECT * FROM production.products
WHERE list_price > (SELECT AVG(list_price) FROM production.products);

-- Part b
SELECT * FROM production.products
WHERE list_price < (SELECT AVG(list_price) FROM production.products);

SELECT COUNT(*) FROM production.products
WHERE list_price < (SELECT AVG(list_price) FROM production.products);

-- Part c
SELECT * FROM sales.customers
WHERE customer_id NOT IN (SELECT customer_id FROM sales.orders WHERE customer_id IS NOT NULL);

-- Part d
SELECT * FROM production.products
WHERE product_id NOT IN (SELECT product_id FROM sales.order_items WHERE product_id IS NOT NULL);


-- Question 9: Derived Tables (Subquery in FROM)
-- Part a
SELECT AVG(order_cnt) as avg_ord, MIN(order_cnt) as min_ord, MAX(order_cnt) as max_ord
FROM (
    SELECT staff_id, COUNT(*) as order_cnt
    FROM sales.orders
    GROUP BY staff_id
) as sub;

-- Part b
SELECT AVG(total_amt) as overall_avg
FROM (
    SELECT c.customer_id, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_amt
    FROM sales.customers c
    JOIN sales.orders o ON c.customer_id = o.customer_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) as cust_spent;


-- Question 10: Subquery in SELECT
-- Part a
SELECT product_id, product_name, list_price,
       (SELECT SUM(quantity) FROM sales.order_items oi WHERE oi.product_id = p.product_id) as units_sold
FROM production.products p;

-- Part b
SELECT order_id, order_date,
       (SELECT COUNT(*) FROM sales.order_items oi WHERE oi.order_id = o.order_id) as item_count,
       (SELECT MAX(list_price) FROM sales.order_items oi WHERE oi.order_id = o.order_id) as max_price
FROM sales.orders o;

-- Part c
SELECT product_id, product_name, list_price,
       list_price - (SELECT AVG(list_price) FROM production.products) as diff
FROM production.products;


-- Question 11: Challenge query
SELECT c.customer_id, c.first_name, c.last_name, 
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > (
    SELECT AVG(t.spent)
    FROM (
        SELECT SUM(oi2.quantity * oi2.list_price * (1 - oi2.discount)) as spent
        FROM sales.customers c2
        JOIN sales.orders o2 ON c2.customer_id = o2.customer_id
        JOIN sales.order_items oi2 ON o2.order_id = oi2.order_id
        GROUP BY c2.customer_id
    ) as t
)
ORDER BY total_spent DESC;