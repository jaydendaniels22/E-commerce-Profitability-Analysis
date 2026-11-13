-- Verify order level costs add up correctly

SELECT order_id, customer_id, ROUND(SUM(product_cost + shipping_cost + platform_fee + transaction_fee) OVER (PARTITION BY customer_id ORDER BY order_id), 2) AS Calculated_Running_Total
FROM orders;

SELECT customer_id, SUM(total_costs) OVER(PARTITION BY customer_id ORDER BY order_id) as Running_Total
FROM orders;