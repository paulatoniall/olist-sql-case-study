--BLOCO E

-- 1. Classificar pedidos por prazo de entrega: "adiantado", "no prazo" ou "atrasado".
select ood.order_id, ood.order_estimated_delivery_date, ood.order_delivered_customer_date,
    case
        when ood.order_delivered_customer_date = '' then 'não entregue'
        when ood.order_delivered_customer_date < ood.order_estimated_delivery_date then 'adiantado'
        when ood.order_delivered_customer_date = ood.order_estimated_delivery_date then 'no prazo'
        else 'atrasado'
    end as status_entrega
from olist_orders_dataset ood;
 
 
-- 2. Classificar clientes por faixa de gasto total: "bronze", "prata", "ouro".
select ood.customer_id, sum(ooid.price) as gasto_total,
    case
        when sum(ooid.price) < 50 then 'bronze'
        when sum(ooid.price) < 150 then 'prata'
        else 'ouro'
    end as faixa
from olist_order_items_dataset ooid
inner join olist_orders_dataset ood on ooid.order_id = ood.order_id
group by ood.customer_id;
 
 
-- 3. Classificar produtos por faixa de peso: "leve", "médio", "pesado".
select opd.product_id, opd.product_weight_g,
	case
        when opd.product_weight_g < 500 then 'leve'
        when opd.product_weight_g <= 2000 then 'médio'
        else 'pesado'
    end as faixa_peso
from olist_products_dataset opd;
 
 
-- 4. Classificar pagamentos como "à vista" ou "parcelado", sinalizando parcelamentos longos.
select oopd.order_id, oopd.payment_type, oopd.payment_installments,
    case
        when oopd.payment_installments = 1 then 'à vista'
        when oopd.payment_installments > 6 then 'parcelado longo'
        else 'parcelado'
    end as tipo_pagamento
from olist_order_payments_dataset oopd;