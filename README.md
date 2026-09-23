# Desafio SQL — Base Olist (E-commerce Brasileiro)

Este repositório contém os scripts `.sql` (blocos A a I) desenvolvidos a partir da base
pública da Olist, importada localmente em PostgreSQL via DBeaver.

## Estrutura dos arquivos

| Arquivo | Conteúdo |
|---|---|
| `bloco_A.sql` | Consultas simples (SELECT, WHERE, ORDER BY, LIMIT) |
| `bloco_B.sql` | Joins entre tabelas |
| `bloco_C.sql` | Funções agregadas + GROUP BY + HAVING |
| `bloco_D.sql` | Subqueries (correlacionadas e não correlacionadas) |
| `bloco_E.sql` | Classificação de dados com CASE WHEN |
| `bloco_F.sql` | CTEs (WITH) |
| `bloco_G.sql` | Views |
| `bloco_H.sql` | Functions parametrizadas (relatórios de leitura) |
| `bloco_I.sql` | Window functions (RANK, SUM OVER, LAG) |

Cada consulta está comentada com a pergunta de negócio que ela responde.

## Principais insights encontrados

### Faturamento concentrado geograficamente
O estado de **SP concentra ~37% de todo o faturamento** da base (R$ 5,9 milhões de um
total de R$ 15,8 milhões), seguido de RJ (13,4%) e MG (11,7%). Os 3 primeiros estados
somam mais da metade do faturamento total — o negócio depende fortemente da região
Sudeste.

### Entregas: mais atraso do que "não entrega"
Do total de ~99,4 mil pedidos:
- **3,0%** nunca chegaram a ser marcados como entregues.
- **7,9%** foram entregues, mas depois da data estimada (atraso real).

Ou seja, o problema de "prazo estourado" é bem maior do que o de "pedido sumido" — vale
mais investigar a causa dos atrasos do que a causa dos pedidos não concluídos.

### Reputação por categoria: eletrônicos/utilidades saem pior
Olhando categorias com pelo menos 30 avaliações (pra não deixar categorias pequenas
distorcerem a média), as piores notas médias são:

| Categoria | Nota média | Nº avaliações |
|---|---|---|
| fraldas_higiene | 3.26 | 39 |
| moveis_escritorio | 3.49 | 1.687 |
| fashion_roupa_masculina | 3.64 | 131 |
| telefonia_fixa | 3.68 | 262 |
| artigos_de_festas | 3.77 | 43 |

`moveis_escritorio` chama atenção por ter volume alto (quase 1.700 avaliações) *e* nota
baixa — não é ruído estatístico, é um problema real de categoria.

### Quase 10% dos vendedores avaliados têm reputação ruim
De 3.090 vendedores com pelo menos uma avaliação, **304 (≈10%) têm nota média abaixo de
3** — uma fatia relevante que merece atenção de qualidade/suporte ao vendedor.

### Frete pode superar o valor do produto
Em **3,2% dos pedidos (3.159 de 98.666)**, o frete pago foi maior que o valor dos itens
comprados — geralmente produtos baratos com entrega para regiões distantes. Isso é um
ponto de atenção para estratégia de frete grátis/subsidiado em produtos de baixo valor.

### Cartão de crédito domina as formas de pagamento
| Forma de pagamento | Pedidos |
|---|---|
| credit_card | 76.505 |
| boleto | 19.784 |
| voucher | 3.866 |
| debit_card | 1.528 |
| not_defined | 3 |

Cartão de crédito responde por ~77% dos pedidos — qualquer instabilidade nesse meio de
pagamento teria impacto desproporcional no negócio.

## Observações técnicas sobre os dados (relevantes para quem for reusar as queries)

- As colunas de data em `olist_orders_dataset` vieram da importação como `TEXT`, e
  valores ausentes chegaram como **string vazia (`''`)**, não `NULL`. Qualquer `CASE`/
  `WHERE` que dependa de "pedido não entregue" precisa checar os dois casos
  (`IS NULL OR = ''`), a não ser que a tabela já tenha passado por um `UPDATE` de
  limpeza convertendo `''` em `NULL`.
- Divisões dentro de `ROUND(..., 2)` no Postgres exigem cast explícito para `numeric`
  (`ROUND((a/b)::numeric, 2)`), já que divisão entre valores costuma retornar
  `double precision`, tipo para o qual `ROUND` de 2 argumentos não existe.
- Pedidos podem ter múltiplos itens e múltiplos registros de pagamento — qualquer
  `JOIN` direto entre `order_items` e `payments` multiplica linhas por pedido. As
  queries de agregação neste projeto tratam isso com `GROUP BY`/subqueries dedicadas
  para não inflar somas e médias.
