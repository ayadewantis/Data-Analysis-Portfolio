-- Optimizing Business Growth Through Customer and Revenue Analytics --

-- Impact of Discounts on Profitability --
--- Provides insights into whether discount strategies drive sales or reduce profitability.
--- Helps determine the optimal discount level that attracts customers without harming business profits.
--- Analyze whether discounts are more effective for specific products.
--- Adjust promotional strategies based on the impact of discounts on profit.
SELECT
    discount, 
    COUNT(order_id) AS total_orders,
    SUM(sales) AS total_sales, 
    SUM(profit) AS total_profit, 
    AVG(profit / NULLIF(sales, 0)) AS avg_profit_margin
FROM `Orders.Order`
GROUP BY discount
ORDER BY discount

-- Most Profitable Regions --
--- Identifies regions/cities with the highest sales and profits for potential business expansion.
--- Helps tailor marketing strategies based on the most profitable areas.
--- Increase marketing investment in already profitable areas.
SELECT
    region, 
    SUM(sales) AS total_sales, 
    SUM(profit) AS total_profit
FROM `Orders.Order`
GROUP BY region
ORDER BY total_profit DESC
LIMIT 10

-- Customer Churn Prediction --
--- Losing customers is expensive, and predicting churn allows proactive retention strategies.
--- Helps reduce marketing costs by focusing on customers who are likely to leave.
WITH customer_orders AS (
    SELECT 
        customer_id, 
        COUNT(order_id) AS total_orders, 
        MAX(order_date) AS last_order_date 
    FROM `Orders.Order`
    GROUP BY customer_id
),
churned_customers AS (
    SELECT 
        customer_id, 
        total_orders, 
        last_order_date, 
        DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) AS days_since_last_order
    FROM customer_orders
)
SELECT 
    customer_id, 
    total_orders, 
    days_since_last_order, 
    CASE 
        WHEN days_since_last_order > 180 THEN 'High Risk of Churn'
        WHEN days_since_last_order BETWEEN 90 AND 180 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk
FROM churned_customers
ORDER BY days_since_last_order DESC

-- Customer Profitability Segmentation --
--- Not all customers contribute equally to profitability.
--- Helps identify which customers deserve premium offers and extra services.
WITH customer_value AS (
    SELECT 
        customer_id, 
        customer_name, 
        SUM(sales) AS total_spent, 
        SUM(profit) AS total_profit, 
        COUNT(order_id) AS total_orders
    FROM `your_project.your_dataset.orders_new_edited`
    GROUP BY customer_id, customer_name
)
SELECT 
    customer_id, 
    customer_name, 
    total_spent, 
    total_profit, 
    total_orders,
    CASE 
        WHEN total_profit > 2000 THEN 'High-Value Customer'
        WHEN total_profit BETWEEN 500 AND 2000 THEN 'Mid-Value Customer'
        ELSE 'Low-Value Customer'
    END AS customer_segment
FROM customer_value
ORDER BY total_profit DESC

-- Customer Retention Analysis --
--- Identifies returning customers to assess loyalty.
--- Helps in designing retention programs.
WITH customer_orders AS (
    SELECT 
        customer_id, 
        COUNT(DISTINCT order_id) AS order_count
    FROM `Orders.Order`
    GROUP BY customer_id
)
SELECT 
    COUNT(CASE WHEN order_count = 1 THEN customer_id END) AS one_time_customers,
    COUNT(CASE WHEN order_count > 1 THEN customer_id END) AS repeat_customers,
    COUNT(customer_id) AS total_customers,
    ROUND(COUNT(CASE WHEN order_count > 1 THEN customer_id END) / COUNT(customer_id) * 100, 2) AS repeat_customer_percentage
FROM customer_orders