--BLOCO I

-- 1. RANK() dos vendedores por faturamento dentro de cada estado
-- "Estado" aqui = estado do VENDEDOR (seller_state), não do cliente, já que a pergunta é sobre onde o vendedor está localizado.
select
    s.seller_id, s.seller_state, sum(oi.price + oi.freight_value) as faturamento,
    rank() over (
        partition by s.seller_state
        order by sum(oi.price + oi.freight_value) desc
    ) as ranking
from olist_order_items_dataset oi
inner join olist_sellers_dataset s on s.seller_id = oi.seller_id
group by s.seller_id, s.seller_state
order by s.seller_state, ranking;
 
 
--2. Faturamento mensal acumulado (SUM(...) OVER (ORDER BY ...)) por vendedor.
with faturamento_mensal_vendedor as (
    select oi.seller_id, date_trunc('month', o.order_purchase_timestamp::timestamp) as mes, sum(oi.price + oi.freight_value) as faturamento
    from olist_order_items_dataset oi
    inner join olist_orders_dataset o on o.order_id = oi.order_id
    group by oi.seller_id, date_trunc('month', o.order_purchase_timestamp::timestamp)
)
select
    seller_id, mes, faturamento, sum(faturamento) over (
        partition by seller_id
        order by mes
    ) as faturamento_acumulado
from faturamento_mensal_vendedor
order by seller_id, mes;
 
 
--3. Percentual de participação de cada vendedor no faturamento total do seu estado
select s.seller_id, s.seller_state, sum(oi.price + oi.freight_value) as faturamento_vendedor,
    round(
        (
            sum(oi.price + oi.freight_value)
            / sum(sum(oi.price + oi.freight_value)) over (partition by s.seller_state) * 100
        )::numeric
    , 2) as percentual_participacao
from olist_order_items_dataset oi
inner join olist_sellers_dataset s on s.seller_id = oi.seller_id
group by s.seller_id, s.seller_state
order by s.seller_state, percentual_participacao desc;
 
 
--4. Variação de faturamento mês a mês por vendedor (LAG)
with faturamento_mensal_vendedor as (
    select oi.seller_id, date_trunc('month', o.order_purchase_timestamp::timestamp) as mes,  sum(oi.price + oi.freight_value) as faturamento
    from olist_order_items_dataset oi
    inner join olist_orders_dataset o on o.order_id = oi.order_id
    group by oi.seller_id, date_trunc('month', o.order_purchase_timestamp::timestamp)
)
select seller_id, mes, faturamento, lag(faturamento) over (partition by seller_id order by mes) as faturamento_mes_anterior,
    faturamento - lag(faturamento) over (partition by seller_id order by mes) as variacao_absoluta,
    round(
        (
            (faturamento - lag(faturamento) over (partition by seller_id order by mes))
            / nullif(lag(faturamento) over (partition by seller_id order by mes), 0) * 100
        )::numeric
    , 2) as variacao_percentual
from faturamento_mensal_vendedor
order by seller_id, mes;