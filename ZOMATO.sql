drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--the total amount each customer spent on Zomato--
SELECT
  u.userid,
  SUM(p.price) AS total_amount_spent
FROM
  users u
JOIN
  sales s ON u.userid = s.userid
JOIN
  product p ON s.product_id = p.product_id
GROUP BY
  u.userid
ORDER BY
  u.userid;

--how many days each customer has visited Zomato--
  SELECT
  u.userid,
  COUNT(DISTINCT s.created_date) AS days_visited
FROM
  users u
JOIN
  sales s ON u.userid = s.userid
GROUP BY
  u.userid
ORDER BY
  u.userid;

 --first product purchased by each customer--
 select * from
 (select*,rank()over(partition by userid order by created_date) rnk from sales)u where rnk=1

 --what is the most purchased item on the menuu and how many times was it purchased by all customer --
 WITH ProductPurchaseCounts AS (
  SELECT
    product_id,
    COUNT(*) AS purchase_count
  FROM
    sales
  GROUP BY
    product_id
)

SELECT
  p.product_name AS most_purchased_item,
  PPC.purchase_count AS purchase_count_by_all_customers
FROM
  ProductPurchaseCounts PPC
JOIN
  product p ON PPC.product_id = p.product_id
ORDER BY
  PPC.purchase_count DESC;


-- calculate which item was the popular for each customer--
  select* from
  (select*,rank() over (partition by userid order by cnt desc) rnk from
  (select userid,product_id,count(product_id)cnt from sales group by userid,product_id)u)p
  where rnk=1


--tem was purchased first by the customer after they become a member--
WITH FirstPurchaseAfterMembership AS (
  SELECT
    u.userid,
    FIRST_VALUE(s.product_id) OVER (PARTITION BY u.userid ORDER BY s.created_date) AS first_purchased_item
  FROM
    users u
  JOIN
    sales s ON u.userid = s.userid
  LEFT JOIN
    goldusers_signup g ON u.userid = g.userid
  WHERE
    g.gold_signup_date IS NOT NULL
    AND s.created_date > g.gold_signup_date
)

SELECT DISTINCT
  userid,
  first_purchased_item
FROM
  FirstPurchaseAfterMembership;

-- total orders and amount spend for each member before they become a member--
  SELECT
  u.userid,
  COUNT(s.product_id) AS total_orders,
  SUM(p.price) AS total_amount_spent
FROM
  users u
LEFT JOIN
  sales s ON u.userid = s.userid
LEFT JOIN
  product p ON s.product_id = p.product_id
LEFT JOIN
  goldusers_signup g ON u.userid = g.userid
WHERE
  s.created_date < g.gold_signup_date OR g.gold_signup_date IS NULL
GROUP BY
  u.userid;

  --rank all the  transactions of the customer--
SELECT
  userid,
  product_id,
  created_date,
  RANK() OVER (PARTITION BY userid ORDER BY created_date) AS transaction_rank
FROM
  sales
  order by transaction_rank;


 


