# E-commerce-Profitability-Analysis Project
# https://analystbuilder.com/projects/e-commerce-profitability-analysis-KvrTi

Cleaning is handled by clean_data.py, which strips the UTF-8 BOM from products.csv, parses marketing_spend.month, and asserts both cost integrity and the gross-to-net bridge before writing. The reconciliation block re-derives every headline figure and fails the script if anything drifts

# Problems

Top-line revenue looks healthy, but the CEO suspects that not all product categories and sales channels are actually profitable once you account for shipping, returns, platform fees, and marketing costs. The company did $1M+ in gross revenue over the past two years, but net margins have been shrinking. The CEO wants to know which product categories and sales channels are truly profitable after all costs, which marketing platforms are delivering the best return on ad spend, and whether the return rate is eating into margins.

# Questions to answer

1. What is the average profit margin by product category? Which categories are the most and least profitable, and what is driving the difference (product cost, shipping, returns, or discounts)?

2. How does profitability differ across sales channels (Website, Mobile App, Marketplace, Social Commerce)? Which channel has the best and worst profit per order after accounting for platform fees?

3. What is the return rate by category and channel? Estimate how much total revenue was lost to returns over the analysis period.

4. Analyze the marketing spend data: Which advertising platform delivers the best ROAS (Return on Ad Spend)? Are there any platforms where the company is spending money but not getting a positive return?

5. If the CEO asked you to cut 20% of the marketing budget, which platforms and months would you recommend reducing spend on? Support your recommendation with data.

# Steps to solution
1. **Cleaned the three raw CSVs in Excel and loaded them into MySQL as the tables orders, products and marketing_spend**.

2. **Checked cost integrity at order level**. Confirmed that product_cost + shipping_cost + platform_fee + transaction_fee = total_costs. A per-customer running total (SUM() OVER (PARTITION BY customer_id ORDER BY order_id)) built from the four cost columns matched the running total of total_costs (e.g. 228.47 for the final row of one customer).
   
3. **Category profitability**. Grouped orders by primary_category. Margin is calculated as SUM(profit) / SUM(net_revenue), not the average of per-order margins, so large orders carry proportionate weight. Totals come straight from orders; joining to products or marketing_spend without a key was avoided because it duplicates order rows.

4. **Cost drivers**. For each category, calculated product cost, shipping, discounts and refunds as a % of gross revenue (SUM(cost) / SUM(gross_revenue)) to see what separates high- and low-margin categories.

5. **Channel analysis**. Grouped orders by channel and compared profit margin, average profit per order (AVG(profit)), and total platform fees (also per order and as a share of gross revenue).
   
6. **Returns**. Return rate is SUM(returned = 'YES') / COUNT(*) by category and by channel. Revenue lost to returns is SUM(refund_amount). A gross-to-net bridge (gross - discounts - refunds) confirmed that net_revenue is already after refunds, so profit is not overstated by returns.

7. **Marketing ROI**. Grouped marketing_spend by platform. ROAS is SUM(revenue_attributed) / SUM(spend), because averaging row-level ratios over-weights small campaigns.

8. **Reconciled marketing against actual orders (see Data Gathered)**. Attributed revenue turned out to be about 34x actual order revenue, so absolute ROAS figures are treated as unreliable and only the relative ranking of platforms is used. The budget-cut estimate in Question 5 is based on actual order data instead.

# Data Gathered
| Order Net Revenue | Order Profit | Attributed Revenue | Marketing Spend |
|---:|---:|---:|---:|
| $236,318.37 | $56,333.83 | $8,146,615.20 | $503,506.14 |

Gross-to-net bridge for the 2,00 orders in the dataset:
| Gross Revenue |   Discounts  |    Refunds   |  Net Revenue |
|---:|---:|---:|---:|
| $277,969.13 | -$21,068.31 | -$20,581.00 | $236,318.37

The bridge reconciles to within about $1.45. The dataset holds $277,969.13 of gross revenue.

Derived from the figures above:
Metric	Value
Overall profit margin (profit / net revenue)	                                  23.84%
Average net revenue per order	                                                  $118.16
Average profit per order	                                                      $28.17
Marketing spend per order	                                                      $251.75
Net revenue per $1 of marketing spend	                                          $0.47
Order profit minus marketing spend (assuming order profit excludes marketing)  -$447,172.31
Attributed revenue vs. actual net revenue	                                      34.5x
Discounts + refunds as % of gross revenue	                                      14.98%

# Answers to the questions
## 1. Profit margin by product category and what drives it

Cost drivers are shown as a % of gross revenue.

| Category | Profit margin | Product cost | Shipping | Discounts | Refunds | Total of four |
|----------|---------------|--------------|----------|-----------|---------|---------------|
| Home & Kitchen | 25.37% | 39.99 | 16.16 | 7.06 | 7.58 | 70.79 |
| Food & Beverage | 24.76% | 38.77 | 17.47 | 7.35 | 9.50 | 73.09 |
| Sports | 23.50% | 41.90 | 18.46 | 8.32 | 5.36 | 74.04 |
| Clothing | 19.99% | 40.90 | 19.84 | 7.79 | 8.55 | 77.08 |
| Beauty | 17.39% | 41.16 | 24.79 | 8.39 | 4.15 | 78.49 |
| Books | 11.94% | 39.96 | 27.94 | 6.51 | 9.40 | 83.81 |
| Toys | 26.15% | 39.94 | 17.25 | 7.72 | 6.32 | 71.23 |
| Electronics | 31.13% | 38.00 | 13.50 | 7.40 | 7.71 | 66.61 |

The company-wide margin is 23.84%. **Books is the least profitable category (11.94%).** Among the categories with a margin figure, **Electronics is the most profitable (31.13%)**.

**Shipping is the main driver.** Product cost is almost the same everywhere (38% to 42%) and discounts are a minor factor (6.5% to 8.4%). Shipping, however, ranges from 13.5% (Electronics) to 27.94% (Books). Comparing Books with Home & Kitchen, the gap in total cost is 13.0 points, of which shipping accounts for 11.8 (27.94% vs 16.16%), refunds 1.8 (9.40% vs 7.58%), discounts -0.6 and product cost nothing. Beauty has the second-highest shipping burden (24.79%). Clothing's weakness is a mix of shipping (19.84%) and returns (8.55%). For the categories with a margin figure, the margin ranking follows the total of the four cost percentages exactly.

Bringing the three weakest categories up to the company average would add about **$4,628** in profit: Books +$2,243, Clothing +$1,209, Beauty +$1,177.

## 2. Profitability by sales channel

| Channel | Orders | Avg profit per order | Profit margin | Platform fees | Fees % of gross revenue | Fees per order |
|---------|--------|----------------------|---------------|---------------|-------------------------|----------------|
| Mobile App | 589 | $36.32 | 29.76% | $0 | 0% | $0 |
| Website | 795 | $31.60 | 27.01% | $0 | 0% | $0 |
| Social Commerce | 197 | $17.11 | 15.37% | $1,944.93 | 7.35% | $9.87 |
| Marketplace | 419 | $15.40 | 13.03% | $7,949.69 | 13.79% | $18.97 |

**Mobile App has the best profit per order ($36.32); Marketplace has the worst ($15.40).** Profit per order is after platform fees, which are already inside `total_costs`.

The two channels that charge fees are the two least profitable. Marketplace fees (13.79% of revenue) are almost exactly the size of its margin gap to Website (13.98 points), and the fee per order ($18.97) is larger than the profit per order ($15.40). Social Commerce's fees explain only part of its 11.64-point gap to Website; it also has the highest return rate of any channel (9.14%), which likely accounts for much of the remainder.

## 3. Return rate by category and channel

Overall, 144 of 2,000 orders were returned (7.2%).

| Category | Orders | Returned | Return rate | Refunds % of gross revenue |
|----------|--------|----------|-------------|----------------------------|
| Electronics | 267 | 23 | 8.61% | 7.71% |
| Books | 239 | 20 | 8.37% | 9.40% |
| Clothing | 293 | 24 | 8.19% | 8.55% |
| Sports | 292 | 21 | 7.19% | 5.36% |
| Toys | 257 | 18 | 7.00% | 6.32% |
| Home & Kitchen | 200 | 12 | 6.00% | 7.58% |
| Beauty | 205 | 12 | 5.85% | 4.15% |
| Food & Beverage | 247 | 14 | 5.67% | 9.50% |

| Channel | Orders | Returned | Return rate |
|---------|--------|----------|-------------|
| Social Commerce | 197 | 18 | 9.14% |
| Mobile App | 589 | 43 | 7.30% |
| Website | 795 | 56 | 7.04% |
| Marketplace | 419 | 27 | 6.44% |

By order count, **Electronics (8.61%) and Social Commerce (9.14%) have the highest return rates.** By value, Food & Beverage (9.50% of revenue) and Books (9.40%) lose the most. Food & Beverage has the lowest return rate by count (5.67%) but the highest by value, which suggests its returned orders are larger than average.

**Revenue lost to returns: $20,581.00**, or 7.40% of gross revenue, which is equal to about 37% of the $56,334 order profit that remains. Discounts and refunds together take $41,649.31, or 14.98% of gross revenue. Because `net_revenue` is already after refunds, profit already reflects these losses.

## 4. Marketing ROAS by platform

| Platform | Spend | Attributed revenue | ROAS |
|----------|-------|--------------------|------|
| TikTok Ads | $57,229.22 | $1,374,627.17 | 24.02 |
| Influencer | $97,663.12 | $2,216,974.26 | 22.70 |
| Instagram Ads | $65,154.02 | $1,024,639.06 | 15.73 |
| Google Ads | $152,546.48 | $2,194,120.83 | 14.38 |
| Facebook Ads | $106,451.93 | $1,218,572.43 | 11.45 |
| Email Marketing | $24,461.37 | $117,681.45 | 4.81 |

**TikTok has the best ROAS, Email the worst.** No platform falls below 1.0 on attributed revenue, so on paper every platform returns more than it costs.

That picture does not survive a reconciliation with actual orders. Attributed revenue ($8.15M) is about 34.5x actual net revenue ($236K), so the ROAS values above are inflated and should be used only to rank platforms against each other. Measured against real orders, the company earns **$0.47 of net revenue and $0.11 of profit per $1 of marketing spend**. Marketing spend per order ($251.75) is more than twice the average net revenue per order ($118.16), and the company spends more on marketing ($503,506) than its entire order profit ($56,334).

## 5. Cutting 20% of the marketing budget

A 20% cut is **$100,701.23**.

**Platforms:** take it from the two lowest-ROAS platforms, Email Marketing (cut 100%, $24,461.37) and Facebook Ads (cut about 72%, $76,239.86). Total: $100,701.23. This protects TikTok, Influencer and Instagram, which return the most per dollar.

**Worst-case check (uses actual orders, not attribution):** assume every order is marketing-driven and revenue falls in proportion to the 20% spend cut. Net revenue would drop by $47,263.67 and profit by $11,266.77, against savings of $100,701.23. **Net gain even in that worst case: $89,434.46.**

Monthly ROAS was ranked for Email Marketing and Facebook Ads. Email is cut entirely because it has the lowest overall ROAS. Facebook is cut from the lowest-ROAS months first: Sep-25, Aug-24, Nov-25, Mar-25, Jan-25, Oct-24, Nov-24, May-25, Feb-25, Oct-25, Jan-24, Apr-24, Aug-25, Jul-25, Jul-24, Mar-24, Jun-25, and 39% of Dec-24. This reaches the exact 20% cut of $100,701.23.


# Recommendations to CEO
1. **Cut marketing spend by 20% ($100,701) from Email and Facebook.** Cut Email Marketing entirely ($24,461.37). Cut Facebook Ads in the lowest-ROAS months listed above plus 39% of Dec-24 ($1,882.03), totaling $76,239.86. Marketing spend ($503,506) is larger than total order profit ($56,334), and every $1 spent returns only $0.47 in net revenue. Even if revenue fell in proportion to the cut, the company would be about $89,434 better off. Pair this with a fix to attribution tracking, because platforms are reporting 34x more revenue than orders actually show.
2. **Recover Marketplace and Social Commerce platform fees ($9,895).** Marketplace orders earn $15.40 profit each, but the fee on each order is $18.97. Pricing Marketplace items to cover the fee would lift profit per order to about $34, in line with Website ($31.60). Social Commerce would rise from $17.11 to about $27 per order. Alternatively, steer repeat buyers to the own-brand Website and App. Recovery is worth up to $9,895 if volume holds.
3. **Cut shipping costs in Books, Beauty and Clothing.** Shipping is 27.94% of Books revenue, against 16.16% for Home & Kitchen, and accounts for 11.8 of Books' 13.0-point cost gap. Beauty is at 24.79% and Clothing at 19.84%. Options include a shipping fee or higher free-shipping threshold, bundling items into one parcel and renegotiating carrier rates. Reaching the 23.84% company average in these three categories adds about $4,628 ($2,243 Books, $1,209 Clothing, $1,177 Beauty).
4. **Reduce returns.** Returns cost $20,581 (7.40% of gross revenue). The highest return rates are Social Commerce (9.14%) and Electronics (8.61%), and by value Food & Beverage and Books (about 9.5% of revenue each). Cutting refunds by a quarter would add about $5,145.

# Limitations
• Order profit assumed to exclude marketing spend.
• Attributed revenue does not reconcile with order revenue.
• Dataset holds 2,000 orders / $277,969 gross revenue, not $1M+.
• Recommendation estimates assume volume does not change.
• Month-level cut recommendations are based on relative attributed ROAS ranking.
