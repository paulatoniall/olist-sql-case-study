--BLOCO H

/*1. Criar a procedure/function sp_relatorio_vendedor(id_vendedor, data_inicio, data_fim), que retorna faturamento, ticket médio e nota médiade avaliação 
 * do vendedor no período informado — sem alterar nenhum dado.*/

create or replace function sp_relatorio_vendedor(id_vendedor text, data_inicio date, data_fim date)
returns table (faturamento numeric, ticket_medio numeric, nota_media numeric)
language sql
as $$
    select
        sum(ooid.price + ooid.freight_value) as faturamento,
        avg(ooid.price) as ticket_medio,
        (
            select avg(oord.review_score)
            from olist_order_items_dataset ooid2
            inner join olist_orders_dataset ood2 on ood2.order_id = ooid2.order_id
            inner join olist_order_reviews_dataset oord on oord.order_id = ooid2.order_id
            where ooid2.seller_id = id_vendedor
            and ood2.order_purchase_timestamp::date between data_inicio and data_fim
        ) as nota_media
    from olist_order_items_dataset ooid
    inner join olist_orders_dataset ood on ood.order_id = ooid.order_id
    where ooid.seller_id = id_vendedor
    and ood.order_purchase_timestamp::date between data_inicio and data_fim;
$$;
 
-- uso: select * from sp_relatorio_vendedor('id_do_vendedor', '2017-01-01', '2017-12-31');
select * from sp_relatorio_vendedor('3442f8959a84dea7ee197c632cb2df15', '2017-01-01', '2017-12-31');

/*2. Criar a procedure/function sp_relatorio_categoria(categoria,data_inicio, data_fim), que retorna faturamento total e 
ticket médio da categoria de produto no período informado.*/

create or replace function sp_relatorio_categoria(categoria_nome text, data_inicio date, data_fim date)
returns table (faturamento_total numeric, ticket_medio numeric)
language sql
as $$
    select
        sum(ooid.price + ooid.freight_value) as faturamento_total,
        avg(ooid.price) as ticket_medio
    from olist_order_items_dataset ooid
    inner join olist_products_dataset opd on opd.product_id = ooid.product_id
    inner join olist_orders_dataset ood on ood.order_id = ooid.order_id
    where opd.product_category_name = categoria_nome
    and ood.order_purchase_timestamp::date between data_inicio and data_fim;
$$;

-- uso: select * from sp_relatorio_categoria('beleza_saude', '2017-01-01', '2017-12-31');
select * from sp_relatorio_categoria('beleza_saude', '2017-01-01', '2017-12-31');