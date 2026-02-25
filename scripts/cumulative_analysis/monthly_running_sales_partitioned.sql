-- Outer query: Displays monthly sales and calculates yearly running total
SELECT 
    t.order_month,                          -- Formatted year-month
    t.total_sales,                          -- Total sales aggregated for each month
    SUM(t.total_sales) OVER (
        PARTITION BY t.order_year           -- Resets the running total at the start of each year
        ORDER BY t.order_month              -- Accumulates sales in chronological month order
    ) AS running_total_sales                -- Yearly cumulative (running) total of sales
FROM
(
    -- Subquery: Aggregates sales by year and month
    SELECT
        YEAR(order_date) AS order_year,     -- Extracts the year from order_date
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,  -- Formats order_date to year-month
        SUM(sales_amount) AS total_sales    -- Calculates total sales per month
    FROM gold_fact_sales                    -- Source fact table containing sales transactions
    WHERE YEAR(order_date) IS NOT NULL      -- Excludes records where year is NULL
    GROUP BY order_year, order_month        -- Groups data by year and month
) AS t;                                     -- Alias required for subquery in MySQL