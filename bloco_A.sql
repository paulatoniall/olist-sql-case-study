--BLOCO A

--1. Listar os 20 pedidos com status delivered mais recentes, ordenados pela data de entrega.
select ood.order_id, ood.order_status, ood.order_delivered_customer_date from olist_orders_dataset ood
where order_status = 'delivered' order by ood.order_delivered_customer_date desc
limit 20;

--2. Listar todos os produtos de uma categoria específica (usando a tabela de tradução para filtrar pelo nome em português).
select opd.product_id, opd.product_category_name, pcnt.product_category_name_english
from olist_products_dataset opd
inner join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
where pcnt.product_category_name = 'instrumentos_musicais';

--3. Listar os métodos de pagamento distintos utilizados na base
select distinct payment_type from olist_order_payments_dataset oopd;

--4. Listar os produtos com peso (product_weight_g) acima de 10kg, ordenados do mais pesado para o mais leve.
select opd.product_id, opd.product_weight_g, opd.product_category_name
from olist_products_dataset opd 
where opd.product_weight_g > 10000 
order by opd.product_weight_g desc;

