/*
====================================================================
Purpose: Analyze yearly product sales performance
Description:
    - Calculates total yearly sales per product.
    - Computes the average sales per product across all years.
    - Determines the difference between each year's sales and 
      the product's overall average.
    - Classifies performance as Above Average, Below Average, or Average.
====================================================================
*/

-- Step 1: Create a Common Table Expression (CTE) to calculate
-- total sales per product per year
WITH yearly_product_sales AS
(
    SELECT 
        YEAR(order_date) AS order_year,          -- Extract year from order date
        p.product_name,                          -- Product name from dimension table
        SUM(f.sales_amount) AS current_sales     -- Total sales per product per year
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_products p
        ON f.product_key = p.product_key         -- Join fact and dimension tables
    WHERE YEAR(order_date) IS NOT NULL           -- Exclude records without valid year
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)

-- Step 2: Calculate average sales and performance difference
SELECT
    order_year,                                  -- Sales year
    product_name,                                -- Product name
    current_sales,                               -- Total sales for the year
    
    -- Average yearly sales per product (window function)
    AVG(current_sales) OVER 
        (PARTITION BY product_name) AS avg_sales,
    
    -- Difference between current year sales and product average
    current_sales - AVG(current_sales) OVER 
        (PARTITION BY product_name) AS diff_avg,
    
    -- Classification of yearly performance compared to average
    CASE 
        WHEN current_sales - AVG(current_sales) OVER 
             (PARTITION BY product_name) > 0 
            THEN 'Above Average'
            
        WHEN current_sales - AVG(current_sales) OVER 
             (PARTITION BY product_name) < 0 
            THEN 'Below Average'
            
        ELSE 'Average'
    END AS avg_change

FROM yearly_product_sales

-- Order results for better readability and trend analysis
ORDER BY product_name, order_year;