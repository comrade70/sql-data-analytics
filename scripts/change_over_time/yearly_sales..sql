/*
=============================================================
Yearly Sales Summary
=============================================================
Purpose:
    This query calculates total sales revenue per year
    to evaluate annual business performance trends.

Description:
    - Extracts the year from order_date
    - Aggregates total sales_amount per year
    - Excludes NULL order dates
    - Sorts results chronologically
=============================================================
*/

SELECT
    -- Extract year and monthfrom order_date
    YEAR(order_date) AS order_year,

    -- Total revenue generated in the month
    SUM(sales_amount) AS total_sales,

    -- Number of unique customers who made purchases in the year
    COUNT(DISTINCT customer_key) AS total_customers,

    -- Total quantity of products sold in the month
    SUM(quantity) AS total_quantities

FROM
    gold_fact_sales

WHERE
    -- Exclude records where order_date is NULL
    YEAR(order_date) IS NOT NULL

GROUP BY
    -- Group results by year
    YEAR(order_date)

ORDER BY
    -- Sort results in chronological order
    YEAR(order_date);