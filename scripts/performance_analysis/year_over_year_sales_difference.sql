/*
====================================================================
Purpose: Analyze yearly product sales performance
Description:
    - Calculates total yearly sales per product.
    - Computes the average sales per product across all years.
    - Determines the difference between each year's sales and 
      the product's overall average.
    - Classifies performance as Above Average, Below Average, or Average.
    - Calculates previous year (PY) sales.
    - Determines Year-over-Year (YoY) sales change and trend direction.
====================================================================
*/

-- ================================================================
-- Step 1: Create a Common Table Expression (CTE) 
-- to calculate total sales per product per year
-- ================================================================
WITH yearly_product_sales AS
(
    SELECT 
        YEAR(order_date) AS order_year,          -- Extract year from order date
        p.product_name,                          -- Product name from dimension table
        SUM(f.sales_amount) AS current_sales     -- Aggregate total sales per product per year
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_products p
        ON f.product_key = p.product_key         -- Join fact table with product dimension
    WHERE YEAR(order_date) IS NOT NULL           -- Exclude records without valid year
    GROUP BY 
        YEAR(f.order_date),                      -- Group by extracted year
        p.product_name                           -- Group by product name
)

-- ================================================================
-- Step 2: Calculate performance metrics using window functions
-- ================================================================
SELECT
    order_year,                                  -- Sales year
    product_name,                                -- Product name
    current_sales,                               -- Total sales for the year
    
    -- ------------------------------------------------------------
    -- Average yearly sales per product (Window Function)
    -- Calculates average across all years for each product
    -- ------------------------------------------------------------
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
    END AS avg_change,
    
    -- ------------------------------------------------------------
    -- Previous Year (PY) Sales
    -- LAG retrieves sales from the previous year
    -- Partition ensures calculation is done per product
    -- Order ensures correct chronological comparison
    -- ------------------------------------------------------------
    LAG(current_sales) OVER 
        (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    
    -- Year-over-Year (YoY) difference
    -- Measures change compared to previous year
    current_sales - LAG(current_sales) OVER 
        (PARTITION BY product_name ORDER BY order_year) AS diff_py_sales,
    
    -- YoY trend classification
    CASE 
        WHEN current_sales - LAG(current_sales) OVER 
             (PARTITION BY product_name ORDER BY order_year) > 0 
            THEN 'Increasing'
            
        WHEN current_sales - LAG(current_sales) OVER 
             (PARTITION BY product_name ORDER BY order_year) < 0 
            THEN 'Decreasing'
            
        ELSE 'No Difference'      -- Includes first year (NULL comparison) or exact match
    END AS py_change

FROM yearly_product_sales

-- Order results by product and year for proper trend visualization
ORDER BY product_name, order_year;