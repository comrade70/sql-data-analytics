/*
====================================================================
Purpose: Segment customers based on Llifespan and spending behavior
Description:
    - Calculates total spending per customer.
    - Determines first and last purchase dates.
    - Computes customer lifespan in months.
    - Segments customers into VIP, TEGULAR, or NEW.
    - Counts total customers in each segment.
====================================================================
*/

-- Step 1: Create a Common Table Expression (CTE)
-- This calculates total spending and lifespan per customer
WITH customer_spending AS
(
    SELECT
        c.customer_key,
        
        -- Total amount spent by each customer
        SUM(f.sales_amount) AS total_spending,
        
        -- First purchase date
        MIN(f.order_date) AS first_order,
        
        -- Most recent purchase date
        MAX(f.order_date) AS last_order,
        
        -- Customer lifespan in months
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
        
    FROM 
        gold_fact_sales f
        
    -- Join fact table with customer dimension
    LEFT JOIN 
        gold_dim_customers c
        ON f.customer_key = c.customer_key
        
    -- Group by customer to aggregate spending and dates
    GROUP BY 
        c.customer_key
)

-- Step 2: Segment customers based on lifespan and spending
SELECT 
    customer_segment,
    
    -- Count number of customers in each segment
    COUNT(customer_key) AS total_customer
    
FROM 
(
    SELECT
        customer_key,
        total_spending,
        lifespan,
        
        -- Customer segmentation logic
        CASE 
            -- High lifespan and high spending customers
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            
            -- High lifespan but lower spending customers
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'REGULAR'
            
            -- Customers with short lifespan
            ELSE 'NEW'
            
        END AS customer_segment
        
    FROM customer_spending
    
) AS t

-- Group customers by segment
GROUP BY customer_segment

-- Display highest customer segment count first
ORDER BY total_customer DESC;