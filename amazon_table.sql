-- Data Wrangling

create schema amazon_schema;
show databases;
use amazon_schema;
 
select * from amazon;
 
 -- Rename columns with spaces
alter table amazon
rename column `invoice id` to invoice_id,
rename column `customer type` to customer_type,
rename column `product line` to product_line,
rename column `unit price` to unit_price,
rename column `tax 5%` to VAT,
rename column `payment` to payment_method,
rename column `gross margin percentage` to gross_margin_percentage,
rename column `gross income` to gross_income;

-- update time column to suit timestamp datatype
update amazon
set time = REPLACE(`time`,`time`, CONCAT(`date`,' ', `time`));

-- modify the datatypes
alter table amazon
modify column invoice_id varchar(30),
modify column branch varchar(5),
modify column city varchar(30),
modify column customer_type varchar(30),
modify column gender varchar(10),
modify column product_line varchar(100),
modify column unit_price decimal(10, 2),
modify column quantity float(6, 4),
modify column vat decimal(10,2),
modify column total decimal(10,2),
modify column `date` date,
modify column `time` timestamp,
modify column payment_method varchar(30),
modify column cogs decimal(10,2),
modify column gross_margin_percentage float(11, 9),
modify column gross_income decimal(10, 2),
modify column rating float(3, 1);

-- check for null values in each column
select * from amazon where invoice_id is NULL;
select * from amazon where branch is NULL;
select * from amazon where city is NULL;
select * from amazon where customer_type is NULL;
select * from amazon where gender is NULL;
select * from amazon where product_line is NULL;
select * from amazon where unit_price is NULL;
select * from amazon where quantity is NULL;
select * from amazon where VAT is NULL;
select * from amazon where total is NULL;
select * from amazon where `date` is NULL;
select * from amazon where `time` is NULL;
select * from amazon where payment_method is NULL;
select * from amazon where cogs is NULL;
select * from amazon where gross_margin_percentage is NULL;
select * from amazon where gross_income is NULL;
select * from amazon where rating is NULL;

-- Feature Engineering
-- add timeofday, dayname and monthname columns
alter table amazon
add column timeofday varchar(20);

-- update timeofday values
update amazon
set timeofday = (case
 when time(`time`) between "00:00:00" and "12:00:00" then "Morning"
 when time(`time`) between "12:01:00" and "16:00:00" then "Afternoon"
 else "Evening"
 end);

-- update dayname column
alter table amazon
add column dayname varchar(20);

update amazon
set dayname = dayname(`date`);

-- update monthname column
alter table amazon 
add column monthname varchar(20);

update amazon
set monthname = monthname(`date`);

select * from amazon;

-- Q1 : What is the count of distinct cities in the dataset?
-- A1 : There are 3 cities (Yangon, Naypyitaw, Mandalay).
select distinct(city) from amazon;

-- Q2 : For each branch, what is the corresponding city?
-- A2 : (Branch - city) A - Yangon, B - Mandalay, C - Naypyitaw
select distinct(branch), city from amazon;

-- Q3 : What is the count of distinct product lines in the dataset?
-- A3 : 6 product_lines 
select distinct(product_line) from amazon;

-- Q4 : Which payment method occurs most frequently?
-- A4 : Ewallet is the most frequently used payment method
select count(payment_method) as pay_meth_count, payment_method from amazon
group by payment_method
order by pay_meth_count desc
limit 1;

-- Q5 : Which product line has the highest sales?
-- A5 : Electronic accessories is having the highest sales.
select product_line, sum(quantity) as sales
from amazon
group by product_line
order by sales desc
limit 1;

-- Q6 : How much revenue is generated each month?
-- A6 : Jan - 116292.11, Feb - 97219.58, Mar - 109455.74
select sum(total) as revenue, monthname
from amazon
group by monthname;

-- Q7 : In which month did the cost of goods sold reach its peak?
-- A7 : January
select monthname, sum(cogs) as cogs
from amazon
group by monthname
order by cogs desc
limit 1;

-- Q8 : Which product line generated the highest revenue?
-- A8 : Food and beverages
select product_line, sum(total) as revenue
from amazon
group by product_line
order by revenue desc
limit 1;

-- Q9 : In which city was the highest revenue recorded?
-- A9 : Naypyitaw
select city, sum(total) as revenue
from amazon
group by city
order by revenue desc
limit 1;

-- Q10 : Which product line incurred the highest Value Added Tax?
-- A10 : Food and beverages
select product_line, sum(VAT) as VAT
from amazon
group by product_line
order by VAT desc
limit 1;

-- Q11 : For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- A11 : 
-- select product_line,
select avg(quantity) from amazon;
select product_line, case 
when avg(quantity) > 6 then "Good"
else "Bad"
end as quality
from amazon
group by product_line;

-- Q12 : Identify the branch that exceeded the average number of products sold.
-- A12 : A,B,C
select branch, sum(quantity)
from amazon
group by branch
having sum(quantity) > (select avg(quantity) from amazon);

-- Q13 : Which product line is most frequently associated with each gender?
-- A13 : Fashion accessories - female, health and beauty - male
select product_line, gender, 
count(gender) as gender_count
from amazon
group by gender, product_line
order by gender_count desc;

-- Q14 : Calculate the average rating for each product line.
-- A14 : 
select product_line, avg(rating)
from amazon
group by product_line;

-- Q15 : Count the sales occurrences for each time of day on every weekday.
-- A15 : Mon : (Morning - 21, Afternoon - 48 , Evening - 56 )
--       Tues : (Morning - 36, Afternoon - 53, Evening - 69)
--       Wed : (Morning - 22, Afternoon - 61 , Evening - 60)
--       Thurs : (Morning - 33, Afternoon - 49, Evening - 56)
--       Fri : (Morning - 29, Afternoon - 58, Evening - 52)
--       Sat : (Morning - 28, Afternoon - 55, Evening - 81)
--       Sun : (Morning - 22, Afternoon - 53, Evening - 58)
select timeofday, dayname, count(invoice_id)
from amazon
group by timeofday, dayname
order by dayname;

-- Q16 : Identify the customer type contributing the highest revenue.
-- A16 : Member
select customer_type, sum(total) as revenue
from amazon
group by customer_type
order by revenue desc
limit 1;

-- Q17 : Determine the city with the highest VAT percentage.
-- A17 : Naypyitaw
select city, max(VAT) as VAT
from amazon
group by city
order by VAT desc
limit 1;

-- Q18 : Identify the customer type with the highest VAT payments.
-- A18 : Member
select customer_type, max(VAT) as VAT
from amazon
group by customer_type
order by VAT desc
limit 1;

-- Q19 : What is the count of distinct customer types in the dataset?
-- A19 : Member - 501, Normal - 499
select customer_type, count(*)
from amazon
group by customer_type;

-- Q20 : What is the count of distinct payment methods in the dataset?
-- A20 : Ewallet - 345, Cash - 344, Credit card - 311
select payment_method, count(*)
from amazon
group by payment_method;

-- Q21 : Which customer type occurs most frequently?
-- A21 : Member
select customer_type, count(*) as type_count
from amazon
group by customer_type
order by type_Count desc
limit 1;

-- Q22 : Identify the customer type with the highest purchase frequency.
-- A22 : Refer to previous query, Member

-- Q23 : Determine the predominant gender among customers.
-- A23 : Female
select gender, count(*) as gender_count
from amazon
group by gender
order by gender_count desc
limit 1;

-- Q24 : Examine the distribution of genders within each branch.
-- A24 : A - {M : 179, F: 161}, B - {M : 170, F: 162}, C - {M:150, F:178}
select branch, gender, count(gender) as gender_count
from amazon
group by branch, gender
order by branch;

-- Q25 : Identify the time of day when customers provide the most ratings.
-- A25 : Afternoon
select timeofday, avg(rating) as rating
from amazon
group by timeofday
order by rating desc;

-- Q26 : Determine the time of day with the highest customer ratings for each branch.
-- A26 : A - Evening, B - Afternoon, C - Evening
select timeofday, max(rating) as rating
from amazon
where branch = 'A'
group by timeofday
order by rating desc;

select timeofday, max(rating) as rating
from amazon
where branch = 'B'
group by timeofday
order by rating desc;

select timeofday, max(rating) as rating
from amazon
where branch = 'C'
group by timeofday
order by rating desc;

-- Q27 : Identify the day of the week with the highest average ratings.
-- A27 : Monday
select dayname, avg(rating) as rating from amazon
group by dayname
order by rating desc;

-- Q28 : Determine the day of the week with the highest average ratings for each branch.
-- A28 : A - Friday, B - Monday, C - Friday
select dayname, avg(rating) as rating
from amazon
where branch = 'A'
group by dayname
order by rating desc
limit 1;

select dayname, avg(rating) as rating
from amazon
where branch = 'B'
group by dayname
order by rating desc
limit 1;

select dayname, avg(rating) as rating
from amazon
where branch = 'C'
group by dayname
order by rating desc
limit 1;
