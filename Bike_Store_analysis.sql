-- Which store has the highest number of sales 

select top(1) s.store_name,count(o.order_id) as no_of_order
from sales.orders o inner join sales.stores s
on o.store_id=s.store_id
group by s.store_name
order by no_of_order desc


--Which store the sales was highest and for which month 

select  s.store_name,sum(i.list_price * quantity *(1-discount)) total_sales,MONTH(o.order_date) as months
from sales.orders o inner join sales.stores s
on o.store_id=s.store_id inner join sales.order_items i
on i.order_id=o.order_id
group by s.store_name,MONTH(o.order_date)
order by total_sales desc


--How many orders each customer has placed (give me top 10 customers)

select top(10) o.customer_id,c.first_name+c.last_name,count(o.order_id)
from sales.orders o inner join sales.customers c
on o.customer_id = c.customer_id
group by o.customer_id,c.first_name+c.last_name
order by count(o.order_id) desc


--Which are the TOP 3 selling product 

select top(3)p.product_name , count(i.product_id)
from sales.order_items i inner join   production.products p
on i.product_id=p.product_id
group by p.product_name
order by COUNT(i.product_id) desc


--Which was the first and last order placed by the customer who has placed the maximum number of orders 

select top(1) with ties o.customer_id ,c.first_name+c.last_name as customer_name,count(o.order_id) as no_of_order,MAX(o.order_id) as last_order_id,MIN(o.order_id) as first_order_id,MAX(o.order_date) as last_order_date,MIN(o.order_date) as first_order_date
from sales.orders o inner join sales.customers c
on o.customer_id = c.customer_id
group by o.customer_id,c.first_name+c.last_name
order by count(o.order_id) desc


--Write a query that lists the names of the 5 products with the highest price provided that the product has a model_year equal to 2018.

select top(5) p.product_name,sum(p.list_price)
from production.products p
where p.model_year=2018
group by p.product_name
order by sum(p.list_price) desc


-- Write a query that returns product name, total price and total quantity of products for each product with the keyword 'Ladies' in the product name

select p.product_name,SUM(p.list_price*s.quantity),sum(s.quantity)
from production.products p inner join production.stocks s
on p.product_id=s.product_id
where p.product_name like '%Ladies%'
group by p.product_name


/*Write a query to get information about products that have not been sold at any stores or are out of stock (quantity = 0), 
results should return store name and product name.*/

select distinct p.product_name,ss.store_name,p.product_id
from   sales.order_items i  right outer join   production.products p 
 on p.product_id =i.product_id    left outer join production.stocks s
on p.product_id=s.product_id  inner join sales.stores ss
on s.store_id=ss.store_id  
where  s.quantity=0 or p.product_id !=i.product_id


--Products that have not been sold at any stores or are out of stock

select distinct p.product_name
from sales.order_items i right outer join production.products p
on i.product_id = p.product_id left join production.stocks s
on p.product_id = s.product_id inner join sales.stores st
on s.store_id= st.store_id
where i.product_id is null or s.quantity = 0


---Products that have not been sold at any stores or didn't send to any stock

select distinct st.store_name, p.product_name
from sales.order_items i right outer join production.products p
on i.product_id = p.product_id full outer join production.stocks s
on p.product_id = s.product_id inner join sales.stores st
on s.store_id = st.store_id
where i.product_id is null or s.product_id  is null

/*Write a query to get information about order code (order_id), customer name (customer_name), store name (store_name), total product quantity (total_quantity)
and total order value (total_net_value) knowing order value (net_value) calculated by the formula quantity * list_price * (1 - discount)*/

select o.order_id,c.first_name,s.store_name,sum(i.quantity) ,sum(quantity * list_price * (1 - discount)) as "total order value"
from sales.orders o inner join sales.customers c
on o.customer_id=c.customer_id inner join sales.stores s
on o.store_id=s.store_id inner join sales.order_items i 
on o.order_id =i.order_id
group by o.order_id,c.first_name,s.store_name