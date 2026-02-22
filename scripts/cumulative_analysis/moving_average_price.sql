-- Outer query: Displays yearly sales and calculates running total sales, and moving average price across years
SELECT 
    t.order_year,                           -- Extracted year from order_date
    t.total_sales,                          -- Total sales aggregated for each year
    SUM(t.total_sales) OVER (
        ORDER BY t.order_year               -- Orders years chronologically for cumulative calculation
    ) AS running_total_sales,                -- Running (cumulative) total of yearly sales
    
    AVG(t.avg_price) OVER (
        ORDER BY t.order_year               -- Orders years chronologically for cumulative calculation
    ) AS moving_average_price                -- moving average price
FROM
(
    -- Subquery: Aggregates total sales per year
    SELECT
        YEAR(order_date) AS order_year,     -- Extracts year from order_date
        SUM(sales_amount) AS total_sales,   -- Computes total sales for each year
        AVG(price) AS avg_price				-- Computes average price
    FROM gold_fact_sales                    -- Source fact table containing sales transactions
    WHERE YEAR(order_date) IS NOT NULL      -- Excludes records where year is NULL
    GROUP BY YEAR(order_date)               -- Groups data by year
) AS t;                                     -- Alias required for subquery in MySQL