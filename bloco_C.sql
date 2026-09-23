--BLOCO C

--1. Faturamento total por estado do cliente.
select ocd.customer_state, SUM(ooid.price + ooid.freight_value) as faturamento_total from olist_orders_dataset ood
inner join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id
inner join olist_order_items_dataset ooid on ooid.order_id = ood.order_id 
group by ocd.customer_state
order by faturamento_total desc;

--2. Top 10 vendedores por faturamento.
select ooid.seller_id, sum(ooid.freight_value + ooid.price) as faturamento_total from olist_order_items_dataset ooid
group by ooid.seller_id 
order by faturamento_total desc
limit 10;

--3. Ticket médio por categoria de produto.
select opd.product_category_name, avg(ooid.price) as media_preco from olist_order_items_dataset ooid
inner join olist_products_dataset opd on opd.product_id = ooid.product_id
group by opd.product_category_name
order by media_preco desc;

--4. Vendedores com nota média de avaliação abaixo de 3 (HAVING AVG(...) < 3).
select seller_id, avg(review_score) as media_avaliacao
from (
    select distinct ooid.order_id, ooid.seller_id, oord.review_score
    from olist_order_items_dataset ooid
    inner join olist_order_reviews_dataset oord on ooid.order_id = oord.order_id
) 
group by seller_id
having avg(review_score) < 3
order by media_avaliacao;

--5. Quantidade de pedidos por forma de pagamento (GROUP BY payment_type).
select oopd.payment_type, count(distinct oopd.order_id) as qtd_pedidos from olist_order_payments_dataset oopd
group by oopd.payment_type
order by qtd_pedidos desc;

--6. Peso médio dos produtos por categoria.
select opd.product_category_name, avg(opd.product_weight_g) as media_peso from olist_products_dataset opd
group by opd.product_category_name
order by media_peso desc;

--7. Número médio de parcelas (AVG(payment_installments)) por categoria de produto.
select opd.product_category_name, avg(oopd.payment_installments) as media_parcelas from olist_order_payments_dataset oopd
inner join olist_order_items_dataset ooid on oopd.order_id = ooid.order_id
inner join olist_products_dataset opd on opd.product_id = ooid.product_id
group by opd.product_category_name;