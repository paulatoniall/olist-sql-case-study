--BLOCO D

-- 1. Clientes cujo gasto total está acima da média geral de gasto por cliente.
select ood.customer_id, sum(ooid.price) as gasto_total
from olist_order_items_dataset ooid
inner join olist_orders_dataset ood on ooid.order_id = ood.order_id
group by ood.customer_id
having sum(ooid.price) > (
    select avg(gasto.total)
    from (
        select sum(ooid2.price) as total
        from olist_order_items_dataset ooid2
        inner join olist_orders_dataset ood2 on ooid2.order_id = ood2.order_id
        group by ood2.customer_id
    ) gasto
)
order by gasto_total desc;
 
 
-- 2. Produtos que nunca receberam avaliação (NOT EXISTS / NOT IN).
select ood.order_id
from olist_orders_dataset ood
where ood.order_id not in (
    select oord.order_id from olist_order_reviews_dataset oord
);
 
 
-- 3. Vendedores que venderam produtos de mais de 5 categorias diferentes (subquery com COUNT(DISTINCT ...)).
select qc.seller_id, qc.qtd_categorias
from (
    select ooid.seller_id, count(distinct opd.product_category_name) as qtd_categorias
    from olist_order_items_dataset ooid
    inner join olist_products_dataset opd on opd.product_id = ooid.product_id
    group by ooid.seller_id
) qc
where qc.qtd_categorias > 5
order by qc.qtd_categorias desc;
 
 
-- 4. Pedidos cujo valor de frete é maior que o valor total dos itens do próprio pedido.
select distinct ooid.order_id
from olist_order_items_dataset ooid
where (
    select sum(ooid_frete.freight_value)
    from olist_order_items_dataset ooid_frete
    where ooid_frete.order_id = ooid.order_id
) > (
    select sum(ooid_preco.price)
    from olist_order_items_dataset ooid_preco
    where ooid_preco.order_id = ooid.order_id
);