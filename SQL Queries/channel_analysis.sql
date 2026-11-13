-- Channel analysis
SELECT 
    channel,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(gross_revenue), 2) AS Avg_Order_Value,
    ROUND(AVG(profit), 2) AS Avg_Profit,
    ROUND(AVG(platform_fee), 2) AS Avg_Platform_Fee,
    ROUND(SUM(platform_fee) / SUM(gross_revenue) * 100, 2) AS Platform_Fee_Pct_of_Revenue,
    ROUND(SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS Return_Rate_Pct
FROM orders
GROUP BY channel
ORDER BY Avg_Profit DESC;