--BLOCO F

-- 1. Faturamento mensal por estado + variação percentual
with faturamento_mensal as (
    select ocd.customer_state, to_char(ood.order_purchase_timestamp::timestamp, 'yyyy-mm') as mes, sum(ooid.price + ooid.freight_value) as faturamento
    from olist_orders_dataset ood
    inner join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id
    inner join olist_order_items_dataset ooid on ooid.order_id = ood.order_id
    group by ocd.customer_state, to_char(ood.order_purchase_timestamp::timestamp, 'yyyy-mm')
),
dados as (
    select customer_state, mes, faturamento, lag(faturamento) over (
            partition by customer_state
            order by mes
        ) as faturamento_anterior
    from faturamento_mensal
)
select customer_state, mes, faturamento, faturamento_anterior,  (faturamento - faturamento_anterior) / faturamento_anterior * 100 as variacao_pct
from dados
order by customer_state, mes;
 
 
-- 2. Volume de avaliações e nota média por categoria (piores reputações)
with avaliacoes_categoria as (
select opd.product_category_name as categoria, count(oord.review_score) as qtd_avaliacoes, avg(oord.review_score) as nota_media
from olist_order_items_dataset ooid
inner join olist_products_dataset opd on opd.product_id = ooid.product_id
inner join olist_order_reviews_dataset oord on oord.order_id = ooid.order_id
group by opd.product_category_name
)
select * from avaliacoes_categoria
where qtd_avaliacoes >= 30
order by nota_media asc, qtd_avaliacoes desc;
 
 
--3. Frete médio por estado vs média geral
with frete_estado as (
select ocd.customer_state as estado, avg(ooid.freight_value) as frete_medio_estado
from olist_orders_dataset ood
inner join olist_customers_dataset ocd on ocd.customer_id = ood.customer_id
inner join olist_order_items_dataset ooid on ooid.order_id = ood.order_id
group by ocd.customer_state
)
select fe.estado, fe.frete_medio_estado, 
(
select avg(freight_value) 
from olist_order_items_dataset) as frete_medio_geral, fe.frete_medio_estado - (select avg(freight_value) from olist_order_items_dataset) as diferenca
from frete_estado fe
order by diferenca desc;