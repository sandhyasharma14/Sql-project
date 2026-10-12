use store 

select * from sales_store


-- copy
select * into sale from sales_store

select * from sale


-- data cleaning

--step 1: to check for duplicate

select transaction_id,count(*) 
from sale
group by transaction_id 
having count(*)>1;


TXN240646
TXN342128
TXN855235
TXN981773

with cte as(
select *,
ROW_NUMBER() over(partition by transaction_id order by transaction_id) as row_num
from sale
) 
select * from cte 
where transaction_id in ('TXN240646','TXN342128','TXN855235','TXN981773');


-- delete duplicate 

with cte as(
select *,
ROW_NUMBER() over(partition by transaction_id order by transaction_id) as row_num
from sale
)
delete from cte 
where row_num = 2;


--step 2 : correction for headers 
select * from sale 

EXEC sp_rename'sale.quantiy','quantity','column'

EXEC sp_rename'sale.prce','price','column'


--step 3: check for data type

select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'sale' 


--step 4: to check null count

declare @sql nvarchar(max) = '';

select @sql = STRING_AGG(
      'select ''' + column_name + ''' as columnname,
      count(*) as nullcount
      from ' + quotename(table_schema) + '.sale
      where ' + quotename(column_name) + ' is null ',
      ' union all '
)
within group (order by column_name)
from INFORMATION_SCHEMA.COLUMNS
where table_name = ' sale';
 
exec sp_executesql @sql; 


-- treatng null value

select * 
from sale
where transaction_id is null
or
customer_id is null
or 
customer_name is null
or 
customer_age is null
or 
gender is null
or 
product_id is null
or 
product_name is null
or 
product_category is null
or 
quantity is null
or 
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or
status is null; 


delete from sale
where transaction_id is null  

select * from sale
where customer_name ='Ehsaan Ram'

update sale 
set customer_id ='CUST9494'
where transaction_id ='TXN977900'

select * from sale
where customer_name ='Damini Raju'

update sale 
set customer_id ='CUST1401'
where transaction_id ='TXN985663'

select * from sale
where customer_id ='CUST1003'

update sale 
set customer_name ='Mahika Saini',customer_age='35',gender='Male'
where transaction_id ='TXN432798'

select * from sale

--step 5: data cleaning
select distinct gender 
from sale

update sale
set gender='M'
where gender ='Male'

update sale
set gender='F'
where gender ='Female'


select distinct payment_mode
from sale

update sale
set payment_mode='credit card'
where payment_mode='CC'


--Data Analysis--

--1. What are the top 5 most selling product by quantity
select * from sale

select distinct status 
from sale


select top 5 product_name, sum(quantity) as total_quantity
from sale
where status ='delivered'
group by product_name
order by total_quantity desc 

-- Business problem: we don't know which products are most in demand 

-- Business impact: helps piroitizes stock and boost sales through trageted promotions.


--2. which products are most frequently cancelled.

select  top 5 product_name,count(*) as total_cancelled
from sale
where status ='cancelled'
group by product_name
order by  total_cancelled desc;

-- Business problem : frequently cancellations affect revenue and customer trust

-- Business impact : identify poor performing product to improve quality or remove from catalog.


--3.what time of the day has the highest number of purchases.

select * from sale

select 
      case
          when DATEPART(hour,time_of_purchase) between 0 and 5 then 'Night'
          when DATEPART(hour,time_of_purchase) between 6 and 11 then 'Morning'
          when DATEPART(hour,time_of_purchase) between 12 and 17 then 'Afternoon'
          when DATEPART(hour,time_of_purchase) between 18 and 23  then 'Evening'
        end as time_of_day,
        count(*) as total_orders
  from sale
  group by 
        case
          when DATEPART(hour,time_of_purchase) between 0 and 5 then 'Night'
          when DATEPART(hour,time_of_purchase) between 6 and 11 then 'Morning'
          when DATEPART(hour,time_of_purchase) between 12 and 17 then 'Afternoon'
          when DATEPART(hour,time_of_purchase) between 18 and 23  then 'Evening'
        end
        order by total_orders desc;


--business problem: Find the peak sale time

--business impact: Optimize staffing,promotions and server loads.


--4. Who are the top 5 highest spending customer

select * from sale

select top 5
    customer_name,
   format( sum(
     cast(price as bigint)*cast(quantity as bigint)),'C0','en-IN') as total_spend 
from sale
group by customer_name
order by total_spend desc;

--BUSINESS PROBLEM: Identify vip customers.

--business impact: Personlized offers,loyalty,rewards and retention.


--5. Which product categories generate the highest revenue.

select * from sale

select 
      product_category,
     format( sum(
     cast(price as bigint)*cast(quantity as bigint)),'c0','en-IN') as highest_revenue
from sale
group by  product_category
order by   sum(
     cast(price as bigint)*cast(quantity as bigint)) desc;


--business problem: Ideentify the top performing product category.

--business impact: refine product strategey,supply chain,and promotions,allowing
--the business to invest more in high margin or high demand categories.


--6. What is the return/cancellation rate per product category

select * from sale

--CANCELLED
select product_category,
     format(count(case when status='cancelled' then 1 end)*100.0/count(*),'N3')+' %' as cancelled_percentage
from sale
group by product_category
order by cancelled_percentage desc;


--RETURNED
select product_category,
     format(count(case when status='returned' then 1 end)*100.0/count(*),'N3')+' %' as returned_percentage
from sale
group by product_category
order by returned_percentage desc;

--business problem:Mointor dissatisfaction trends per category
--business impact:reduce return,improve product description/expections.


--7.What is the most preferred payment mode ?

select * from sale

select  payment_mode ,count(payment_mode) as total_count 
from sale
group by payment_mode
order by total_count desc;

--business problem:Know which payment option customer prefer
--business impact:Streamline payment processing, prioritize popular modes


--8.How does the age group affect purchasing behavior.

select * from sale

select 
     case 
         when customer_age between 18 and 25 then '18-25'
         when customer_age between 26 and 35 then '26-35'
         when customer_age between 36 and 50 then '36-50'
         else '51+'
     end as customer_age,
     sum(
     cast(price as bigint)*cast(quantity as bigint)) as total_purchase
from sale
group by case 
         when customer_age between 18 and 25 then '18-25'
         when customer_age between 26 and 35 then '26-35'
         when customer_age between 36 and 50 then '36-50'
         else '51+'
     end
order by total_purchase desc;

--business problem:Understand customer demographics.
--business imapct:Trageted markting and product recommendation by age group


--9.What's the monthly sale trends.

select * from sale

--method 1:
select 
     format(purchase_date,'yyyy-MM') as month_year,
     format(sum(
     cast(price as bigint)*cast(quantity as bigint)),'c0','en-IN') as total_sale,
     sum(quantity) as total_quantity
from sale
group by format(purchase_date,'yyyy-MM')

--method 2
select
     YEAR(purchase_date) as years,
     month(purchase_date) as months,
     format(sum(
     cast(price as bigint)*cast(quantity as bigint)),'c0','en-IN') as total_sale,
     sum(quantity) as total_quantity
from sale
group by  YEAR(purchase_date) ,month(purchase_date) 
order by years,months   

--business problem: Sale fluctuations go unnoticed.
--business impact: Plan inventory and markting according to sesonal trends.


--10.Are certain genders buying more specific product categories?

select * from sale

select product_category,gender,
       count(product_category) as total_purchase
from sale
group by product_category,gender
order by gender


--business problem: Gender based product preferences.
--business immpact: Personalized ads, gender-focused campaigns.
