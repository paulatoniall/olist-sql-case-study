--BLOCO B

--1. Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor.
select opd.product_category_name, pcnt.product_category_name_english, olist_order_items_dataset.price,osd.seller_city 
from olist_products_dataset opd 
inner join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
inner join olist_order_items_dataset on olist_order_items_dataset.product_id = opd.product_id
inner join olist_sellers_dataset osd on osd.seller_id = olist_order_items_dataset.seller_id;

--2. Identificar pedidos com atraso na entrega, comparando data estimada com data real de entrega (join entre orders e customers).
select ood.order_estimated_delivery_date, ood.order_delivered_customer_date, ocd.customer_city,ocd.customer_state 
from olist_orders_dataset ood 
inner join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id 
where ood.order_delivered_customer_date > ood.order_estimated_delivery_date;

--3. Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de uma parcela
select ood.order_id, oopd.payment_type from olist_orders_dataset ood 
inner join olist_order_payments_dataset oopd on oopd.order_id = ood.order_id;

--4. Listar produtos junto com a categoria traduzida, incluindo produtos cuja categoria não possui tradução cadastrada (LEFT JOIN com product_category_name_translation).
select opd.product_id, opd.product_category_name, pcnt.product_category_name_english from olist_products_dataset opd 
left join product_category_name_translation pcnt on pcnt.product_category_name = opd.product_category_name;

--5. Identificar pedidos em que o cliente e o vendedor são do mesmo estado
select ooid.order_id, osd.seller_state,	ocd.customer_state 
from olist_order_items_dataset ooid 
inner join olist_orders_dataset ood on ooid.order_id = ood.order_id
inner join olist_customers_dataset ocd on ood.customer_id = ocd.customer_id
inner join olist_sellers_dataset osd on ooid.seller_id = osd.seller_id 
where osd.seller_state = ocd.customer_state 

