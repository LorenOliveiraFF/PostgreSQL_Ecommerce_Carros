-- PROJETO: DASHBOARD DE VENDAS 

-- (Query 1) Receita, leads, conversão e ticket médio mês a mês
-- Colunas: mês, leads (#), vendas (#), receita (k, R$), conversão (%), ticket médio (k, R$)

with 
	table_leads as 
			(SELECT 
				date_trunc('month', visit_page_date)::date AS visitas_mes,
				count(*) as contagem_leads
			FROM 	
				sales.funnel
			GROUP BY visitas_mes),
	
	table_vendas as
			(SELECT 
			 	date_trunc('month', paid_date)::date AS vendas_mes,
				count(paid_date) as qtdcompras_mes,
			 	sum(price * (1+vendas.discount)) as receita
			FROM
				sales.funnel as vendas
			LEFT JOIN 	
				sales.products as produtos
				ON vendas.product_id = produtos.product_id
			WHERE paid_date IS NOT NULL
			GROUP BY vendas_mes)			
SELECT
	leads.visitas_mes as "mês",
	leads.contagem_leads as "leads (#)",	
	vendas.qtdcompras_mes as "vendas (#)",
	(vendas.receita/1000) as "receita (k, R$)",
	(vendas.qtdcompras_mes::float / leads.contagem_leads::float) as "conversão(%)",
	(vendas.receita / vendas.qtdcompras_mes/1000) as "ticket médio(k, R$)"
FROM
	table_leads AS leads
LEFT JOIN
	table_vendas as vendas
	ON leads.visitas_mes = vendas.vendas_mes





-- (Query 2) Estados que mais venderam
-- Colunas: país, estado, vendas (#)
SELECT
	'Brazil' as país,
	clientes.state,
	count(vendas.paid_date) as vendas
FROM 
	sales.funnel as vendas
LEFT JOIN
	sales.customers as clientes
	ON vendas.customer_id = clientes.customer_id
WHERE vendas.paid_date between '2021-08-01' and '2021-08-31'
GROUP BY país, clientes.state
ORDER BY vendas DESC
LIMIT 5








-- (Query 3) Marcas que mais venderam no mês
-- Colunas: marca, vendas (#)
SELECT 
	produtos.brand as marca,
	count(vendas.paid_date) as compras_mes
FROM 
	sales.funnel as vendas
LEFT JOIN
	sales.products as produtos
	ON vendas.product_id = produtos.product_id
WHERE vendas.paid_date between '2021-08-01' and '2021-08-31'
GROUP BY marca
ORDER BY compras_mes DESC
LIMIT 5






-- (Query 4) Lojas que mais venderam no mês
-- Colunas: loja, vendas (#)
SELECT 
	lojas.store_name as loja,
	count(vendas.paid_date) as tot_vendas
FROM
	sales.funnel as vendas
LEFT JOIN
	sales.stores as lojas
	ON vendas.store_id = lojas.store_id
WHERE vendas.paid_date between '2021-08-01' and '2021-08-31'
GROUP BY lojas.store_name
ORDER BY tot_vendas DESC
LIMIT 5











-- (Query 5) Dias da semana com maior número de visitas ao site
-- Colunas: dia_semana, dia da semana, visitas (#)

SELECT
	extract('dow' from visit_page_date) as dia_da_semana,
	case	
		when extract('dow' from visit_page_date) = 0 then 'Domingo'
		when extract('dow' from visit_page_date) = 1 then 'Segunda-Feira'
		when extract('dow' from visit_page_date) = 2 then 'Terça-Feira'
		when extract('dow' from visit_page_date) = 3 then 'Quarta-Feira'
		when extract('dow' from visit_page_date) = 4 then 'Quinta-Feira'
		when extract('dow' from visit_page_date) = 5 then 'Sexta-Feira'
		else 'Sábado' end as semana_escrita,
		count(*)
FROM 	
	sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
GROUP BY dia_da_semana
ORDER BY dia_da_semana

