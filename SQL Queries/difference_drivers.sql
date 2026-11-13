-- Differences
SELECT 
    primary_category,
    ROUND(SUM(product_cost)    / SUM(gross_revenue) * 100, 2) AS Product_Cost_Pct,
    ROUND(SUM(shipping_cost)   / SUM(gross_revenue) * 100, 2) AS Shipping_Pct,
    ROUND(SUM(discount_amount) / SUM(gross_revenue) * 100, 2) AS Discount_Pct,
    ROUND(SUM(refund_amount)   / SUM(gross_revenue) * 100, 2) AS Refund_Pct
FROM orders
GROUP BY primary_category
ORDER BY Product_Cost_Pct DESC;

-- Average profit per order by channel
SELECT 
    channel,
    COUNT(*) AS Orders,
    ROUND(AVG(profit), 2) AS Avg_Profit_Per_Order
FROM orders
GROUP BY channel
ORDER BY Avg_Profit_Per_Order DESC;

-- Return rate by category
SELECT 
    primary_category,
    COUNT(*) AS Orders,
    SUM(returned = 'YES') AS Returned_Orders,
    ROUND(SUM(returned = 'YES') / COUNT(*) * 100, 2) AS Return_Rate_Pct
FROM orders
GROUP BY primary_category
ORDER BY Return_Rate_Pct DESC;

-- Return rate by channel
SELECT 
    channel,
    COUNT(*) AS Orders,
    SUM(returned = 'YES') AS Returned_Orders,
    ROUND(SUM(returned = 'YES') / COUNT(*) * 100, 2) AS Return_Rate_Pct
FROM orders
GROUP BY channel
ORDER BY Return_Rate_Pct DESC;

-- Total revenue lost to returns over the analysis period
SELECT 
    ROUND(SUM(gross_revenue), 2)   AS Gross_Revenue,
    ROUND(SUM(discount_amount), 2) AS Discounts,
    ROUND(SUM(refund_amount), 2)   AS Refunds,
    ROUND(SUM(net_revenue), 2)     AS Net_Revenue,
    ROUND(SUM(refund_amount) / SUM(gross_revenue) * 100, 2) AS Refund_Pct_of_Gross
FROM orders;