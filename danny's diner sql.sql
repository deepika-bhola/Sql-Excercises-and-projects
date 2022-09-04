

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from members;
  select * from sales;
  select * from menu;
  
  -- CASE STUDY
  
  -- 1. What is the total amount each customer spent at the restaurant?
  select sum(m.price)as total_amount,s.customer_id, m.product_name
  from menu as m , sales as s
  where s.product_id=m.product_id
  group by s.customer_id,m.product_name;
  
-- 2. How many days has each customer visited the restaurant?
select count(distinct(order_date)) as visit_count , customer_id
from sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select  s.customer_id,s.order_date,m.product_name
from (select order_date , customer_id , product_id, rank()over(partition by customer_id
order by order_date ) as no from sales) s, menu m
where m.product_id=s.product_id and s.no=1 
group by s.customer_id
;

-- 4. What is the most purchased item on the menu and how many times 
-- was it purchased by all customers?
select  m.product_name , c.orders
from  (select count(product_id) orders , product_id from 
sales group by product_id order by orders desc limit 1) as c , menu m
where m.product_id= c.product_id;

-- 5. Which item was the most popular for each customer?

select  c.customer_id , m.product_name  from
(select count(product_id) orders, product_id, customer_id , rank() over(partition by customer_id
order by count(product_id) desc) as r
from sales 
group by customer_id, product_id) c , menu m 
where c.r=1 and c.product_id=m.product_id
group by c.customer_id;


-- 6. Which item was purchased first by the customer after they became a member?
select  last.customer_id ,m.product_name 
 from (select s.customer_id, s.order_date, s.product_id , m.join_date
 , dense_rank()over(partition by s.customer_id order by s.order_date )as r 
 from sales s , members m 
 where s.order_date>=m.join_date and s.customer_id= m.customer_id) as last, menu as m
 where last.r =1 and m.product_id=last.product_id;
 
 
-- 7. Which item was purchased just before the customer became a member?
select  last.customer_id ,m.product_name 
 from (select s.customer_id, s.order_date, s.product_id , m.join_date
 , dense_rank()over(partition by s.customer_id order by s.order_date desc)as r 
 from sales s , members m 
 where s.order_date<m.join_date and s.customer_id= m.customer_id) as last, menu as m
 where last.r =1 and m.product_id=last.product_id;


-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id , count(s.product_id) as total_items, sum(me.price) as amount
from sales s , members m , menu me
where s.order_date< m.join_date and m.customer_id=s.customer_id and me.product_id=s.product_id
group by customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
-- how many points would each customer have?

select s.customer_id , sum(m.points) 
from (select *, case
when m.product_name = 'sushi' then 2*(m.price)*10
else (m.price)*10 
end as points from menu m) m ,sales s 
where s.product_id=m.product_id
group by customer_id;


-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?


select p.customer_id, sum(p.points) pointss
from (select s.customer_id ,s.order_date , case 
when s.order_date between s.order_date and adddate(s.order_date,6)  then 2*(me.price)*10
when me.product_name='sushi' then 2* (me.price)*10
else me.price *10
end as points
 from members m , menu me, sales s
 where s.customer_id=m.customer_id and me.product_id= s.product_id) as p
 where p.order_date<'2021-01-31'
 group by p.customer_id;
 
 ------------------------
-- BONUS QUESTIONS-------
------------------------

-- Join All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
 
 select k.* , case 
 when me.join_date is null then 'n'
 else 'y'
 end as memb
 from(select s.customer_id , s.order_date , m.price ,m.product_name
 from sales s
 join menu m 
 on s.product_id=m.product_id) as k
 Left join 
 members me
 on k.customer_id=me.customer_id;
 
 
  