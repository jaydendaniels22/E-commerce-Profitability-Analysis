-- Category profitability
WITH category_summary AS (
    SELECT 
        primary_category AS product_category,
        SUM(net_revenue) AS Total_Revenue,
        SUM(total_costs) AS Total_Costs,
        SUM(profit) AS Total_Profit,
        SUM(profit) / SUM(net_revenue) * 100 AS Profit_Margin_Pct
    FROM orders
    GROUP BY primary_category
)
SELECT 
    product_category,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    ROUND(Total_Costs, 2) AS Total_Costs,
    ROUND(Total_Profit, 2) AS Total_Profit,
    ROUND(Profit_Margin_Pct, 2) AS Profit_Margin_Pct,
    RANK() OVER (ORDER BY Total_Profit DESC) AS Profit_Rank,
    RANK() OVER (ORDER BY Profit_Margin_Pct DESC) AS Margin_Rank
FROM category_summary
ORDER BY Profit_Rank;