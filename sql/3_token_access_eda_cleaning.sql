select *
from tokenized_access_logs tal 
limit 10

select count(*)
from tokenized_access_logs tal 

select c.column_name , c.data_type , c.character_maximum_length 
from information_schema."columns" c 
where c.table_name = 'tokenized_access_logs'
order by c.ordinal_position 

SELECT
    "Product",
    "Product"[1] AS first_product_element,
    cardinality("Product") AS product_elements,
    "url",
    "url"[1] AS first_url_element,
    cardinality("url") AS url_elements
FROM public.tokenized_access_logs
LIMIT 5;

SELECT
    MIN(cardinality("Product")) AS min_product_elements,
    MAX(cardinality("Product")) AS max_product_elements,
    MIN(cardinality("url")) AS min_url_elements,
    MAX(cardinality("url")) AS max_url_elements
FROM public.tokenized_access_logs;

create table tokenized_access_logs_clean as
select 
	"Product"[1]::text as "product",
	"Category",
	"Date",
	"Month",
	"Hour",
	"Department",
	"ip",
	"url"[1]::text as "url"
from tokenized_access_logs

select c.column_name , c.data_type , c.character_maximum_length 
from information_schema."columns" c 
where c.table_name = 'tokenized_access_logs_clean'

select distinct talc."Date"  
from tokenized_access_logs_clean talc 
limit 10

select 
	count(distinct talc.product), 
	(select count(distinct sca."Product Name") from supply_chain_analysis sca) 
from tokenized_access_logs_clean talc 

select count(distinct talc."product")
from tokenized_access_logs_clean talc  
inner join supply_chain_analysis sca
on talc."product" = sca."Product Name" 	
/* query took forever to execute */

with tokenized_products as(
	select distinct talc."product" 
	from tokenized_access_logs_clean talc 
),
	transaction_products as(
	select distinct sca."Product Name"
	from supply_chain_analysis sca 
)
select 
	(select count(distinct sca."Product Name") from supply_chain_analysis sca) transaction_products,
	(select count(distinct talc."product") from tokenized_access_logs_clean talc) token_products,
	count(*) as matched_products
from tokenized_products top
inner join transaction_products trp
	on top."product" = trp."Product Name"
/* 72 out of 76 products in the tokenized access logs match those of the transaction products */
	
with matched_products as(
	select distinct talc."product" 
	from tokenized_access_logs_clean talc
	inner join (select distinct sca."Product Name"  from supply_chain_analysis sca ) scaj
	on talc.product = scaj."Product Name" 
)
select 
	count(*) total_token_events,
	round(count(mp."product" )::numeric / count(*) * 100, 2) as matched_event_rate
from tokenized_access_logs_clean talc
left join matched_products mp
	on talc."product" = mp."product"
/* 92% of the products exist in the transactions exist in the token acess, so we will use the table */

alter table tokenized_access_logs_clean  
alter column "Date" type date
using to_timestamp("Date", 'MM/DD/YYYY HH24:MI')::date	
	
select 
	MIN(talc."Date" )::Date min_date_token,
	MAX(talc."Date" )::date max_date_token,
	(select min(sca."order date (DateOrders)")::date from supply_chain_analysis sca) min_date_transactions,
	(select max(sca."order date (DateOrders)")::date from supply_chain_analysis sca) max_date_ttransactions
from tokenized_access_logs_clean talc
/* token access logs is within the same timeframe as the transactions, only started in sep 2017 */