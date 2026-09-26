select *
from supply_chain_raw scr

select *
from supply_chain_raw scr
limit 10

select scr."Order Item Profit Ratio" 
from supply_chain_raw scr 

select count(*)
from supply_chain_raw scr

select count(distinct scr."Order Id" ), count(scr."Order Id" )
from supply_chain_raw scr
/* Number of order IDs: 65,752 -- Number of rows: 180,519 */

select scr."Order Id", count(*)
from supply_chain_raw scr
group by "Order Id"
order by count(*) desc


select scr."Order Id", scr."Product Name" 
from supply_chain_raw scr 
where scr."Order Id" = 33788
/* Some of the order IDs are divided into products, which explains the duplicated order IDs */

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'supply_chain_raw'
ORDER BY ordinal_position;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'supply_chain_raw' and column_name ilike '%date%'
ORDER BY ordinal_position;
/* Dates are varchar */

select scr."Delivery Status", count(scr."Delivery Status" )
from supply_chain_raw scr
group by "Delivery Status"
/* More than half of the shipments are classified under "Late Delivery */

select scr."Delivery Status", AVG(scr."Days for shipping (real)" )
from supply_chain_raw scr 
group by "Delivery Status" 

select scr."Delivery Status", avg(scr."Sales" )
from supply_chain_raw scr 
group by scr."Delivery Status"
/* Almost the same in the 4 stauses */


select scr."Delivery Status", sum(scr."Sales" )
from supply_chain_raw scr 
group by scr."Delivery Status"
/* More than half the sales came from "late delivery" orders */

select scr."Order Country" , sum(scr."Sales" )
from supply_chain_raw scr 
group by scr."Order Country"
order by SUM(scr."Sales" ) desc
limit 10
/* Most sales came from USA */

select scr."Order Country" ,
count(*) num_of_orders,
round(cast(SUM(scr."Sales" ) as numeric),2) as total_sales,
round(cast(avg(scr."Sales" ) as numeric),2) as avg_sales
from supply_chain_raw scr 
group by scr."Order Country"
having count(*) >= 100
order by avg_sales desc, num_of_orders desc
limit 10
/* Avg sales per product or order per country are very different from total sales (Ireland on top) */

select scr."Order Country" , scr."Category Name",
count(*) num_of_orders,
round(cast(SUM(scr."Sales" ) as numeric),2) as total_sales,
round(cast(avg(scr."Sales" ) as numeric),2) as avg_sales
from supply_chain_raw scr 
group by scr."Order Country", scr."Category Name" 
order by SUM(scr."Sales" ) desc
limit 10

select scr."Category Name", sum(scr."Sales" )
from supply_chain_raw scr 
group by "Category Name" 
order by sum(scr."Sales" ) desc
/* Fishing is the highest sold categry in the top selling countries */

select scr."Customer Segment", scr."Order Country",  count(*), sum(scr."Sales" )
from supply_chain_raw scr 
group by scr."Customer Segment", "Order Country"  
order by sum(scr."Sales" ) desc
/* Most sales came from the consumer category */

select scr."Customer Segment", scr."Order Country" , avg(scr."Sales" )
from supply_chain_raw scr 
group by "Customer Segment", "Order Country"
order by avg(scr."Sales" ) desc
/* Highest avg sales came from Home Office in Greece */

select scr."Order Country" , scr."Order Item Discount Rate" 
from supply_chain_raw scr 
order by "Order Item Discount Rate" desc

select scr."Order Item Discount Rate",count(*) num_of_orders, 
sum(scr."Sales" ) total_sales, avg(scr."Sales" ) avg_sales,
avg(scr."Order Item Profit Ratio" ) avg_profit_ratio
from supply_chain_raw scr 
group by scr."Order Item Discount Rate" 
order by avg(scr."Order Item Profit Ratio" ) desc
/* Total sales, no. of orders, avg sales, and profitability are almost the same among all discount rates!! */

select scr."Shipping Mode", count(*) num_of_orders,
sum(scr."Sales" ) total_sales, avg(scr."Sales" ) avg_sales,
avg(scr."Benefit per order"  ) avg_benefit_per_order
from supply_chain_raw scr 
group by scr."Shipping Mode" 
order by avg_benefit_per_order desc
/* Highest number of ordered products and highest sales came from standard class shipping mode */

select scr."order date (DateOrders)" 
from supply_chain_raw scr
where "order date (DateOrders)"  is null

select scr."order date (DateOrders)" 
from supply_chain_raw scr
where "order date (DateOrders)"  = ''

select scr."Sales" 
from supply_chain_raw scr
where scr."Sales"   is null


