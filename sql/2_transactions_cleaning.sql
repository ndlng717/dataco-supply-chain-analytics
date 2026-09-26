select current_database()
/* checking to see if I am in the database I want */

select scr."order date (DateOrders)", scr."shipping date (DateOrders)" 
from supply_chain_raw scr

create table supply_chain_clean as
select *
from supply_chain_raw scr
/* creating a new table for cleaning to avoid messing with the original */

alter table supply_chain_clean 
alter column "order date (DateOrders)" type date
using to_timestamp("order date (DateOrders)", 'MM/DD/YYYY HH24:MI')::date

alter table supply_chain_clean 
alter column "shipping date (DateOrders)" type date
using to_timestamp("shipping date (DateOrders)", 'MM/DD/YYYY HH24:MI')::date

select scc."order date (DateOrders)", scc."shipping date (DateOrders)" 
from supply_chain_clean scc

select column_name, data_type
from information_schema."columns" c 
where c.table_name = 'supply_chain_clean'
and c.column_name = 'order date (DateOrders)' or c.column_name = 'shipping date (DateOrders)'
/* changing data types of dates */

select column_name, data_type
from information_schema."columns" c 
where c.table_name = 'supply_chain_clean'
order by c.ordinal_position

select scc."Late_delivery_risk", scc."Product Status" 
from supply_chain_clean scc 
/* checking columns with suspicious data types. risk is a 0 and 1 flag, while status is all zeros */

select scc."Product Status" 
from supply_chain_clean scc 
where scc."Product Status" <> 0
/* confirm it is all zeros */

select
MIN(scc."Benefit per order" ) as min_benefit,
MAX(scc."Benefit per order" ) as max_benefit,
MIN(scc."Sales" ) as min_sales,
MAX(scc."Sales" ) as max_sales,
MIN(scc."Order Item Quantity" ) as min_quantity,
MAX(scc."Order Item Quantity" ) as max_quantity
from supply_chain_clean scc 
/* one entry with -4,275 benefit */

select *
from supply_chain_clean scc 
where scc."Benefit per order" = (
	select MIN(scc2."Benefit per order" )
	from supply_chain_clean scc2 
);
/* Extreme negative benefit identified and investigated; confirmed as a legitimate loss-making transaction */

select scc."Product Status" 
from supply_chain_clean scc 

select column_name
from information_schema."columns" c 
where c.table_name = 'supply_chain_clean'
/* delete (Order Zipcode, Product Status, Customer Email, Customer Fname, Customer Lname, Customer Password,
 Customer Street, Product Description, Product Image)
 */

create table supply_chain_analysis as
select *
from supply_chain_clean

alter table supply_chain_analysis 
drop column "Order Zipcode",
drop column "Product Status",
drop column "Customer Email",
drop column "Customer Fname",
drop column "Customer Lname",
drop column "Customer Password",
drop column "Customer Street",
drop column "Product Description",
drop column "Product Image"

select *
from supply_chain_analysis sca 
limit 10

select count(column_name)
from information_schema."columns" c 
where c.table_name = 'supply_chain_analysis'
/* 44 from 53 */

select count(*), count(sca)
from supply_chain_analysis sca 
/* same num of rows 180,519 */