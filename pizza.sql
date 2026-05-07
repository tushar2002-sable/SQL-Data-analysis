create database pizza;
use pizza;

show tables;

select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;

-- Total orders by quantity
select count(quantity) as Total_orders from order_details;

-- total revenue 
select sum(p.price * od.quantity) as total_revenue from pizzas p
join order_details od on p.pizza_id = od.pizza_id;

-- total pizzas sold
select sum(quantity) as total_pizzas_sold from order_details;

-- Revenue by size
select p.size, round(sum(od.quantity * p.price)) as revenue from pizzas p 
join order_details od on p.pizza_id = od.pizza_id
group by p.size
order by revenue desc;

select avg(distinct order_id) as avg from order_details;

-- Revenue by Pizza category
select pt.category , sum(od.quantity * p.price ) as revenue_by_category from order_details od
join pizzas p on od.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category 
order by revenue_by_category desc; 

-- Top 5 best selling pizzas by revenue
select pt.name , sum(od.quantity * p.price) as revenue from order_details od
join pizzas p on od.pizza_id  = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name 
order by revenue desc
limit 5;

-- Bottom 5 selling pizzas
select pt.name , round(sum(od.quantity * p.price)) as revenue from order_details od
join pizzas p on od.pizza_id  = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name 
order by revenue asc
limit 5;

-- sales by month
select monthname(o.date) as month,
sum(od.quantity * p.price ) as revenue from order_details od 
join pizzas p on od.pizza_id=p.pizza_id
join orders o on o.order_id = od.order_id
group by month(o.date) , monthname(o.date)
order by month(o.date) desc;

-- order placed after 12 pm
select * from orders 
where Hour(time) >=12;

-- orders by day of week
	select dayname(date) as day_name,
	count(distinct order_id) as total_orders
	from orders
	group by dayofweek(date), dayname(date)
	order by dayofweek(date) ;

-- orders on weekend
select * , dayname(date) as dayname from orders
where dayname(date) in ("saturday","Sunday","Friday");

select * from pizza_types
where category = 'classic';

-- orders on each day
select dayname(date), dayofweek(date) , count(distinct order_id) as total_orders from orders o
group by dayname(date), dayofweek(date);

-- Total quantity sold per pizza
select pizza_id , sum(quantity) as total_orders
from order_details
group by pizza_id
order by total_orders desc;

-- pizzas sold more than 100 times 
select pizza_id, sum(quantity)  as total_quantity
from order_details 
group by pizza_id
having total_quantity > 100
order by total_quantity desc;

-- Revenue by each pizza name
select pt.name , sum(p.price) as revenue  from pizzas p
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue desc
limit 10;

select pizza_id ,count(quantity) as total_quantity from order_details
where quantity >=2
group by pizza_id
order by total_quantity desc;

-- Pizza price higher than average price
select pizza_id , price from pizzas
where price > (select avg(price) from pizzas);

select category, total_varieties from (select category, count(*) as total_varieties from pizza_types
group by category) as nd
order by total_varieties desc;

select category , count(category) as total
from pizza_types 
group by category 
order by total desc;

-- Ranking  pizzas by revenue within each category
select pt.category, pt.name , sum(od.quantity * p.price) as revenue,
rank() over (partition by pt.category order by sum(od.quantity * p.price) desc) as rnk
from order_details od
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category , pt.name;

-- rank by category and name based on revenue
select pt.category , pt.name ,sum(od.quantity * p.price)as revenue , 
rank() over (partition by pt.category order by sum(p.price * od.quantity) desc) as rnk
from order_details od
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name , pt.category;

select dayname(date), max(date) from orders
group by dayname(date);

select max(date) from orders;

-- Orders placed after 12pm
select * from orders
where hour(time) > 12;

select distinct od.pizza_id , od.quantity , o.time from order_details od
join orders o on od.order_id = o.order_id
where hour(o.time) > 12;

-- Using Dense rank to know price of pizza size
select distinct pizza_id , size , price,
dense_rank() over(partition by size  order by price desc) as drnk
from pizzas;

select p.pizza_id , p.size , sum(p.price * od.quantity) as Total_revenue ,
dense_rank() over (partition by p.size order by sum(p.price * od.quantity)) as drnk
from pizzas p 
join order_details od
on p.pizza_id = od.pizza_id
group by  p.pizza_id , p.size
order by Total_revenue asc;

select  * from pizza_types
where name like 'T%';

select  * from pizza_types
where name like 'T%' and category = "classic";

-- Removing Duplicates
delete from pizzas where pizza_id in (
select pizza_id from (
select pizza_id , row_number() over(partition by pizza_id) as rnk
from pizzas) p
where p.rnk > 1);

-- Replacing Values using CASE WHEN
update pizzas
set size = case 
when size = 'L' then 'Large'
when size ='S' then 'Small'
when size ='M' then 'Medium'
else size
End
where size in ('L','S','M');

select * from pizzas;
select * from pizza_types;

show tables;

alter table pizza_types
drop column ingredients;
----------
create view total_revenue as
select sum(p.price * od.quantity) as total_revenue from pizzas p
join order_details od on p.pizza_id = od.pizza_id;

create view total_pizzas_sold as 
select sum(quantity) as total_pizzas_sold from order_details;

create view category_revenue as
select pt.category , sum(od.quantity * p.price ) as revenue_by_category from order_details od
join pizzas p on od.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category 
order by revenue_by_category desc;

create view top_5 as 
select pt.name , sum(od.quantity * p.price) as revenue from order_details od
join pizzas p on od.pizza_id  = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name 
order by revenue desc
limit 5;

create view bottom_5 as
select pt.name , sum(od.quantity * p.price) as revenue from order_details od
join pizzas p on od.pizza_id  = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name 
order by revenue desc
limit 5;

create view month_sales as
select monthname(o.date) as month,
sum(od.quantity * p.price ) as revenue from order_details od 
join pizzas p on od.pizza_id=p.pizza_id
join orders o on o.order_id = od.order_id
group by month(o.date) , monthname(o.date)
order by month(o.date) desc;

create view pizza_revenu as
select pt.name , sum(p.price) as revenue  from pizzas p
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue desc
limit 10;

select *  from orders;

SELECT * 
FROM orders 
WHERE date > (NOW() - INTERVAL 1 MONTH);

use pizza;

-- Handling Null Values
select * from orders
where date is null
	and order_id is null;
    
-- fill/replace null values
select  ifnull(order_id , 0) as order_id , date from orders 
group by order_id, date;

-- Detect Duplicated
select 	order_id , count(*) as count  from orders	
group by order_id 
having count(*) > 1 	
order by count desc;

select * from (
select * , row_number() over ( partition by order_id order by order_id desc) as rnk
from orders) t
where t.rnk > 1;
	
-- keep only first
delete from orders 
where order_id not in (
select * from (
select min(order_id) from orders 
group by order_id) as t);

SET SQL_SAFE_UPDATES = 0;

select gender, 
sum(case when  churn =1 then  1 else 0  end) as 'churned'),
sum(case when churn = 0 then 1  else 0 end) as 'retained') 
from your_table
froup by gender;

select name, salary from employees 
where salary < (select max(salary)   as max from employess )
limit 1;

SELECT DISTINCT salary 
FROM employees 
ORDER BY salary DESC 
LIMIT 1 OFFSET 1;

select name , salary from employees 
where salary = (select distinct salary from employees
				order by salary desc limit 1 offset 1);
