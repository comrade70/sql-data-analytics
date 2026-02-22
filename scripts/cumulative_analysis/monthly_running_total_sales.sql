-- Outer query: Selects monthly sales and calculates running total
SELECT 
    t.order_month,                         -- Formatted year-month of the order date
    t.total_sales,                         -- Total sales aggregated for each month
    SUM(t.total_sales) OVER (ORDER BY t.order_month) AS running_total_sales  -- Cumulative (running) total of sales ordered by month
FROM
(
    -- Subquery: Aggregates total sales per month
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,   -- Extracts year and month from order_date
        SUM(sales_amount) AS total_sales                   -- Calculates total sales for each month
    FROM gold_fact_sales                                   -- Source fact table containing sales records
    WHERE DATE_FORMAT(order_date, '%Y-%m') IS NOT NULL     -- Excludes records where formatted order date is NULL
    GROUP BY order_month                                   -- Groups data by year-month
) AS t;                                                     -- Alias required for subquery in MySQL