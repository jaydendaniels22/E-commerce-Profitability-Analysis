-- Marketing ROI by Platform
WITH platform_metrics AS (
    SELECT
        platform,
        SUM(spend) AS Total_Spend,
        SUM(revenue_attributed) AS Total_Revenue,
        SUM(conversions) AS Total_Conversions,
        SUM(clicks) AS Total_Clicks
    FROM marketing_spend
    GROUP BY platform
)
SELECT
    platform,
    ROUND(Total_Spend, 2) AS Total_Spend,
    ROUND(Total_Revenue / NULLIF(Total_Spend, 0), 2) AS ROAS,
    ROUND(Total_Spend / NULLIF(Total_Conversions, 0), 2) AS CPA,
    ROUND(Total_Spend / NULLIF(Total_Clicks, 0), 2) AS CPC,
    CASE
        WHEN Total_Revenue / NULLIF(Total_Spend, 0) < 1 
            THEN 'Losing money'
        WHEN Total_Revenue / NULLIF(Total_Spend, 0) < 
             (SELECT SUM(Total_Revenue) / SUM(Total_Spend) FROM platform_metrics)
            THEN 'Below average'
        ELSE 'At or above average'
    END AS Performance
FROM platform_metrics
ORDER BY ROAS DESC;

-- Monthly ROAS for the two platforms being cut
WITH monthly AS (
    SELECT
        month,
        platform,
        SUM(spend) AS spend,
        SUM(revenue_attributed) AS revenue
    FROM marketing_spend
    WHERE platform IN ('Email Marketing', 'Facebook Ads')
    GROUP BY month, platform
)
SELECT
    month,
    platform,
    ROUND(spend, 2) AS spend,
    ROUND(revenue, 2) AS attributed_revenue,
    ROUND(revenue / NULLIF(spend, 0), 2) AS roas
FROM monthly
ORDER BY platform, roas ASC;

WITH monthly AS (
    SELECT
        month,
        platform,
        SUM(spend) AS spend,
        SUM(revenue_attributed) AS revenue
    FROM marketing_spend
    WHERE platform = 'Facebook Ads'
    GROUP BY month, platform
),
ranked AS (
    SELECT
        month,
        spend,
        revenue,
        revenue / NULLIF(spend, 0) AS roas,
        ROW_NUMBER() OVER (ORDER BY revenue / NULLIF(spend, 0)) AS roas_rank,
        SUM(spend) OVER (
            ORDER BY revenue / NULLIF(spend, 0)
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_spend
    FROM monthly
)
SELECT *
FROM ranked
ORDER BY roas_rank;