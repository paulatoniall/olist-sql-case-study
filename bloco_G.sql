--BLOCO G

--1. vw_pedidos_completos
create or replace view vw_pedidos_completos as
select ood.order_id, ood.order_status, ood.order_purchase_timestamp, ood.order_delivered_customer_date, ood.order_estimated_delivery_date, ocd.customer_id, ocd.customer_city, ocd.customer_state, ooid.product_id, ooid.seller_id, ooid.price, ooid.freight_value, oopd.payment_type, oopd.payment_installments, oopd.payment_value
from olist_orders_dataset ood
inner join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id
inner join olist_order_items_dataset ooid on ooid.order_id = ood.order_id
inner join olist_order_payments_dataset oopd on oopd.order_id = ood.order_id;
 
--2. vw_avaliacoes_categoria
create or replace view vw_avaliacoes_categoria as
select opd.product_category_name as categoria, count(oord.review_score) as qtd_avaliacoes, avg(oord.review_score) as nota_media
from olist_order_items_dataset ooid
inner join olist_products_dataset opd on opd.product_id = ooid.product_id
inner join olist_order_reviews_dataset oord on oord.order_id = ooid.order_id
group by opd.product_category_name;

