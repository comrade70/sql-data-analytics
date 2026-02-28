/*
====================================================================
Purpose: Segment products into cost ranges and count distribution
Description:
    - Classifies products into cost categories.
    - Aggregates the number of products per cost range.
    - Sorts the result by highest number of products.
====================================================================
*/

-- Create a CTE to define product cost segments
WITH product_segment AS (
    SELECT 
        product_key,      -- Unique identifier for each product
        product_name,     -- Name of the product
        cost,             -- Cost of the product
        
        -- Categorize products based on cost range
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 101 AND 500 THEN '100-500'
            WHEN cost BETWEEN 501 AND 1000 THEN '501-1000'
            ELSE 'ABOVE 1000'
        END cost_range    -- Derived column for cost segmentation
        
    FROM gold_dim_products  -- Source table containing product details
)

-- Query the CTE to count products per cost range
(
    SELECT 
        cost_range,                     -- Cost category label
        COUNT(product_key) AS total_products  -- Total number of products in each segment
    FROM product_segment
    GROUP BY cost_range                 -- Aggregate by cost category
    ORDER BY total_products DESC        -- Sort by highest product count
)