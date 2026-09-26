select * 
from supply_chain_analysis sca 
limit 10

select extract(month from sca."order date (DateOrders)") as month_number 
from supply_chain_analysis sca
/* months numbers */

select to_char(sca."order date (DateOrders)" , 'fmmonth') as month
from supply_chain_analysis sca 
/* months names, using fm to avoid padding */

select
	extract(month from sca."order date (DateOrders)") as month_number,
	to_char(sca."order date (DateOrders)", 'fmmonth') as month,
	count(*) as order_items,
	round(sum(sca."Sales" )::numeric,2) as total_sales,
	round(sum(sca."Benefit per order")::numeric,2) as total_profit 
from supply_chain_analysis sca
where
	extract(year from sca."order date (DateOrders)") <> 2018
group by 
	extract(month from sca."order date (DateOrders)"), 
	to_char(sca."order date (DateOrders)", 'fmmonth')
order by month_number
/* only slight drops in February and December. but no seasonal pattern */

select     
	extract(year from sca."order date (DateOrders)") as year,
	count(*) as order_items,
	sum(sca."Sales") as total_sales,
	round(sum(sca."Benefit per order")::numeric, 2) as total_profit
from supply_chain_analysis sca
where extract(year from sca."order date (DateOrders)") < 2018
group by 
	extract(year from sca."order date (DateOrders)")
order by year
/* slight drop in 2017. 2018 is the lowest, but we only have january there (to be filtered out) */

with yoy_growth as(
	select
		extract(year from sca."order date (DateOrders)") as year,
		count(distinct "Order Id") as num_of_orders,
		lag(count(distinct "Order Id")) over(order by extract(year from sca."order date (DateOrders)"))
		as prev_year_orders,
		round(SUM(sca."Sales" )::numeric,2) as total_sales,
		lag(round(SUM(sca."Sales" )::numeric,2)) over(order by extract(year from sca."order date (DateOrders)"))
		as prev_year_sales,
		round(sum(sca."Order Profit Per Order"  )::numeric,2) as total_profit,
		lag(round(SUM(sca."Order Profit Per Order" )::numeric,2)) 
		over(order by extract(year from sca."order date (DateOrders)")) as prev_year_profit
	from supply_chain_analysis sca
	where extract(year from sca."order date (DateOrders)") < 2018
	group by extract(year from sca."order date (DateOrders)")
	order by year
)
select year,
	num_of_orders,
	prev_year_orders,
	round(((num_of_orders - prev_year_orders)::numeric /prev_year_orders)*100,2) as yoy_orders_growth,
	total_sales,
	prev_year_sales,
	round(((total_sales - prev_year_sales)/prev_year_sales)*100,2) as yoy_sales_growth,
	total_profit,
	prev_year_profit,
	round(((total_profit - prev_year_profit)/prev_year_profit)*100,2) as yoy_profit_growth
from yoy_growth
order by "year"
/* no. of orders declined a bit before rising again. yoy total sales declined slightly then
 majorly. profit margin declined as well, but much less than total sales' decline between 2016 and 2017*/

select 
	extract(year from sca."order date (DateOrders)") as year,
	count(distinct sca."Order Id") as num_of_orders, 
	count(*) as num_of_items,
	round(count(*)::numeric/count(distinct sca."Order Id"),2) as avg_items_per_order,
	round(sum(sca."Sales")::numeric/count(distinct sca."Order Id"),2) as avg_sales_per_order
from supply_chain_analysis sca
where extract(year from sca."order date (DateOrders)") < 2018
group by extract(year from sca."order date (DateOrders)")
order by year
/* num of orders increased, but num of ordered items declined. partially explains the rise in num of orders
 and the decline in sales*/

select 
	sca."Market", 
	count(distinct sca."Order Id" ) as num_of_orders,
	round(sum(sca."Sales")::numeric,2) as total_sales,
	round(sum(sca."Order Profit Per Order")::numeric,2) as total_profit,
	round((sum(sca."Order Profit Per Order")::numeric/sum(sca."Sales")::numeric)*100,2) as profit_margin
from supply_chain_analysis sca 
group by sca."Market"
order by total_sales desc
/* Europe is the highest in both num of orders and total sales, while USCA is the highest in profit margin */


select 
	sca."Order Region", 
	count(distinct sca."Order Id" ) as num_of_orders,
	round(sum(sca."Sales")::numeric,2) as total_sales,
	round(sum(sca."Order Profit Per Order")::numeric,2) as total_profit,
	round((sum(sca."Order Profit Per Order")::numeric/sum(sca."Sales")::numeric)*100,2) as profit_margin
from supply_chain_analysis sca 
group by sca."Order Region"
order by total_sales desc

with country_sales as(
	select 
		sca."Order Region" as region ,
		sca."Order Country" as country , 
		round(SUM(sca."Sales" )::numeric,2) as total_sales,
		row_number() over(partition by sca."Order Region" order by sum(sca."Sales") desc) as ranking
	from supply_chain_analysis sca 
	group by sca."Order Region" , sca."Order Country" 
	order by total_sales desc
)
select 
	cs.region , 
	cs.country , 
	cs.total_sales
from country_sales cs
where cs.ranking =1
order by cs.total_sales desc
/* finding the top selling country in each region */

select 
	sca."Category Name" category, 
	count(distinct sca."Order Id" ) num_of_orders , 
	round(SUM(sca."Sales" )::numeric,2) total_sales,
	round(SUM(sca."Order Profit Per Order" )::numeric,2) total_profit,
	round((sum(sca."Order Profit Per Order" )::numeric/SUM(sca."Sales" )::numeric)*100,2) as profit_margin
from supply_chain_analysis sca 
group by sca."Category Name" 
order by total_sales    desc
/* Fishing is the biggest revenue/profit generator, 
 while Golf Bags & Carts is the most profitable relative to its sales, but with very low num_of_orders. */

with category_sales as(
	select 
		sca."Category Name" category , 
		sca."Product Name" product , 
		round(sum(sca."Sales")::numeric,2)  total_sales ,
		row_number() over(partition by sca."Category Name" order by sum(sca."Sales") desc ) ranking
	from supply_chain_analysis sca 
	group by sca."Category Name" , sca."Product Name"  
)
select category , product , total_sales 
from category_sales 
where ranking <= 3
order by category , total_sales desc
/* highest selling products in each category */

select 
	sca."Shipping Mode" , 
	count(*) num_of_shipped_order_items,
	sum(case when sca."Late_delivery_risk" = 1 then 1 else 0 end) risk_flagged_items, 
	round(avg(sca."Late_delivery_risk")*100,2) late_delivery_risk_rate, 
	round(avg(sca."Days for shipping (real)" )::numeric,2) avg_actual_days , 
	round(avg(sca."Days for shipment (scheduled)")::numeric,2) avg_scheduled_days ,
	round(avg(sca."Days for shipping (real)"  - sca."Days for shipment (scheduled)")::numeric,2)
	avg_shipment_variance
from supply_chain_analysis sca 
group by "Shipping Mode" 
order by late_delivery_risk_rate  desc
/* second class has the highest average shipment variance. 
 first class has the highest number of risk flagged items and second highest variance  */

select 
	sca."Late_delivery_risk", 
	count(*) num_of_ordered_items,
	round(AVG(sca."Days for shipping (real)" - sca."Days for shipment (scheduled)" )::numeric,2)
	avg_shipment_variance,
	round(SUM(sca."Sales" )::numeric,2) total_sales,
	round(AVG(sca."Sales" )::numeric,2) avg_sales, 
	round(sum(sca."Order Profit Per Order" )::numeric,2) total_profit, 
	round(AVG(sca."Order Profit Per Order" )::numeric,2) avg_profit, 
	round(((sum(sca."Order Profit Per Order" )/sum("Sales"))::numeric)*100,2) profit_margin
from supply_chain_analysis sca 
group by "Late_delivery_risk" 
order by "Late_delivery_risk" desc
/* higher risk order items have worse shipping performance and slightly weaker profitability,
despite having the larger volums of sales */

select 
	sca."Customer Segment",  
	count(*) num_of_ordered_items,
	round(AVG(sca."Days for shipping (real)" - sca."Days for shipment (scheduled)" )::numeric,2)
	avg_shipment_variance,
	round(SUM(sca."Sales" )::numeric,2) total_sales,
	round(AVG(sca."Sales" )::numeric,2) avg_sales, 
	round(sum(sca."Order Profit Per Order" )::numeric,2) total_profit, 
	round(AVG(sca."Order Profit Per Order" )::numeric,2) avg_profit, 
	round(((sum(sca."Order Profit Per Order" )/sum("Sales"))::numeric)*100,2) profit_margin
from supply_chain_analysis sca 
group by sca."Customer Segment"
/* Consumer leads all three segments in total sales, total profit, and profit margin */

with product_sales as(
	select 
		sca."Product Name" , 
		count(distinct sca."Order Id" ) num_of_orders, 
		count(*) num_of_items, 
		round(SUM(sca."Sales" )::numeric,2) total_sales, 
		round(sum(sca."Order Profit Per Order")::numeric,2) total_profit,
		round(((sum(sca."Order Profit Per Order")/sum(sca."Sales"))::numeric)*100 ,2) profit_margin  
	from supply_chain_analysis sca 
	where sca."order date (DateOrders)" between '2017-09-01' and '2018-01-31'
	group by sca."Product Name" 
	order by total_sales desc
),
	product_access as(
	select talc."product", count(*) access_events
	from tokenized_access_logs_clean talc 
	where talc."Date" between '2017-09-01' and '2018-01-31'
	group by talc.product 
	order by access_events desc
)
select 
	ps."Product Name" , 
	ps.num_of_orders , 
	ps.num_of_items , 
	ps.total_sales , 
	ps.total_profit , 
	ps.profit_margin , 
	pa.access_events 
from product_sales ps
inner join product_access pa
on ps."Product Name" = pa.product 
order by ps.total_sales desc;
/* comparing access events to sales - no consistent pattern. also, 36 products only out of 76 that were accessed online generated sales */

select 
	distinct talc."product" accessed_products
from tokenized_access_logs_clean talc 
left join supply_chain_analysis sca 
	on talc."product" = sca."Product Name"
	and sca."order date (DateOrders)" between '2017-09-01' and '2018-01-31'
where sca."Product Name" is null
/* 40 products that were accessed online and didn't result in sales */

select 
	sca."Order Status" ,
	count(distinct sca."Order Id") num_of_orders,
	round(sum(sca."Sales")::numeric,2) total_sales, 
	round(sum(sca."Order Profit Per Order" )::numeric,2) total_profit
from supply_chain_analysis sca 
group by sca."Order Status" 
order by total_sales desc

with monthly_sales as(
	select
		extract(year from sca."order date (DateOrders)" )::int as year,
		extract(month from sca."order date (DateOrders)" )::int month_num,
		to_char(sca."order date (DateOrders)", 'FMMonth') as month,
		sum(sca."Sales" )::numeric as total_sales
	from supply_chain_analysis sca 
	group by 
		extract(year from sca."order date (DateOrders)" )::int,
		extract(month from sca."order date (DateOrders)" )::int,
		to_char(sca."order date (DateOrders)", 'FMMonth')
)
select 
	month_num, 
	month, 
	round(max(total_sales) filter(where year = 2015),2) as sales_2015,
	round(max(total_sales) filter(where year = 2016),2) as sales_2016,
	round(max(total_sales) filter(where year = 2017),2) as sales_2017
from monthly_sales
group by month_num, month
/* relatively consistent. A slight usual drop in February each year. A big drop in Nov and Dec of 2017 */




