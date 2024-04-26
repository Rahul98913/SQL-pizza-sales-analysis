show databases ;
use pizzahut ;

-- Q!)  retrieve the total number of orders placed 

select count(orders.order_id) as total_orders from orders ;

-- Q2) Calculate the total revenue generated from pizza sales 

use pizzahut ;
select * from order_details ;

select 
round(sum(pizzas.price * order_details.quantity) ,2) as total_sales
from pizzas join order_details 
on order_details.pizza_id = pizzas.pizza_id ;

-- Q3) Identify the highest-priced pizza.

select pizzas.price, pizza_types.name 
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
order by pizzas.price desc limit 1;

-- Q4) Identify the most common pizza  order

select quantity , count(order_details_id)
from order_details group by quantity ;

-- Q5)  Identify the most comman pizza size orderd

select * from order_details ;  

select pizzas.size , count(order_details.order_details_id) as order_count 
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by  order_count desc ;

-- Q6) List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS pizza_type_count
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY pizza_type_count DESC
LIMIT 5;

-- Q7) Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS pizza_category_sum
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY pizza_category_sum DESC;

-- Q8) Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time); 

-- Q9) Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) from pizza_types group by category ;

-- Q10) Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_orderd_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity; 
    
    -- Q11)  Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name ,
round(sum(pizzas.price * order_details.quantity) ,2) as total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id 
    group by pizza_types.name 
    order by total_revenue desc limit 3;
    
    -- Q12)  Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            0) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Q13 ) Analyze the cumulative revenue generated over time.

select order_date , sum(revenue) over (order by order_date) as cumulative_revenue
from
(select orders.order_date , 
sum(order_details.quantity * pizzas.price) as revenue 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Q14) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category ,name , revenue from 
(select category , name , revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name ,
sum(order_details.quantity * pizzas.price) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category , pizza_types.name) as a) as b 

where rn <= 3 ;
