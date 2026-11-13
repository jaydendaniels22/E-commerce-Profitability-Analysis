WITH m AS (
    SELECT platform, SUM(spend) AS spend, SUM(revenue_attributed) AS revenue
    FROM marketing_spend
    GROUP BY platform
),
o AS (
    SELECT SUM(profit) / SUM(net_revenue) AS margin FROM orders
)
SELECT 
    m.platform,
    ROUND(m.spend, 2) AS Spend_Saved_If_Cut,
    ROUND(m.revenue, 2) AS Attributed_Revenue_Lost,
    ROUND(m.revenue * o.margin, 2) AS Profit_Lost,
    ROUND(m.spend - m.revenue * o.margin, 2) AS Net_Profit_Gain_From_Cutting
FROM m CROSS JOIN o
ORDER BY Net_Profit_Gain_From_Cutting DESC;

WITH c AS (
    SELECT primary_category, SUM(net_revenue) AS rev, SUM(profit) AS profit
    FROM orders GROUP BY primary_category
)
SELECT 
    primary_category,
    ROUND(profit / rev * 100, 2) AS Margin_Pct,
    ROUND(rev * ((SELECT SUM(profit) / SUM(rev) FROM c) - profit / rev), 2) AS Profit_Gained_If_Margin_Hit_Average
FROM c
ORDER BY Margin_Pct;

SELECT 
    channel,
    ROUND(SUM(platform_fee), 2) AS Total_Fees,
    ROUND(SUM(platform_fee) / SUM(gross_revenue) * 100, 2) AS Fee_Pct,
    ROUND(SUM(profit) / SUM(net_revenue) * 100, 2) AS Margin_Pct
FROM orders
GROUP BY channel
ORDER BY Margin_Pct;