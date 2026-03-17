/*
=============================================================
Monthly Sales Performance Summary
=============================================================
Purpose:
    This query aggregates sales data on a monthly basis
    to analyze revenue performance,
    and product demand trends.

Descriptions:
    - Extracts Year-Month from order_date
    - Calculates total sales revenue per month
    - Counts unique customers per month
    - Sums total quantity of products sold per month
    - Orders results chronologically

Table Used:
    gold_fact_sales (fact table containing transactional sales data)
=============================================================
*/

SELECT
    -- Extract year and month from order_date
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,

    -- Total revenue generated in the month
    SUM(sales_amount) AS total_sales,

    -- Number of unique customers who made purchases in the month
    COUNT(DISTINCT customer_key) AS total_customers,

    -- Total quantity of products sold in the month
    SUM(quantity) AS total_quantities

FROM
    gold_fact_sales

WHERE
    -- Exclude records where order_date is NULL
    DATE_FORMAT(order_date, '%Y-%m') IS NOT NULL

GROUP BY
    -- Group results by year-month
    DATE_FORMAT(order_date, '%Y-%m')

ORDER BY
    -- Sort results in chronological order
    DATE_FORMAT(order_date, '%Y-%m');