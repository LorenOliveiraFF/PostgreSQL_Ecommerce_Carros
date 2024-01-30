-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)
with 
	generos_dos_clientes as (
							SELECT
								clientes.customer_id as id_clientes,
								clientes.first_name as nome_clientes,	
								generos.gender as generos_temptables
							FROM 
								sales.customers as clientes
							LEFT JOIN
								temp_tables.ibge_genders as generos
								ON upper(generos.first_name) = clientes.first_name)

SELECT 
	generos_temptables,
	count(vendas.visit_page_date) as datas_visitas
FROM 
	generos_dos_clientes as generos
LEFT JOIN
	sales.funnel as vendas
	ON generos.id_clientes = vendas.customer_id
GROUP BY generos_temptables
		
		
		
		


-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)

with 	
	tab_prof_leads as (
			SELECT 	
				clientes.professional_status,
				count(*)::float as qtd_visitas
			FROM 	
				sales.customers as clientes
			LEFT JOIN
				sales.funnel as vendas
				ON clientes.customer_id  = vendas.customer_id
			GROUP BY clientes.professional_status
		)
SELECT 
	professional_status,
	(qtd_visitas / 30580) as porcent_leads
FROM 
	tab_prof_leads
ORDER BY porcent_leads DESC






-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)
	
with tab_idade as (
					SELECT
						customer_id,
						(current_date - birth_date) / 365 as idade
					FROM
						sales.customers)

SELECT	
	case
		when idade < 20 then '0-20'
		when idade >= 20 and idade < 40 then '20-40'
		when idade >= 40 and idade < 60 then '40-60'
		when idade >= 60 and idade < 80 then '60-80'
		else '80+'
		end as faixa_etaria,
		count(idade)::float / 25109
FROM 
	tab_idade
GROUP BY faixa_etaria
ORDER BY faixa_etaria


-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem

WITH faixa_de_salario as 
						(SELECT 
						 	income,
							case
								when income < 5000 then '0-5000'
									when income >= 5000 and income < 10000 then '5000-10000'
									when income >= 10000 and income < 15000 then '10000-15000'
									when income >= 15000 and income < 20000 then '15000-20000'
									else '20000+' end as faixa_salarial
								FROM sales.customers 
						)
SELECT 
	faixa_salarial, 
	COUNT(*)/25109::float
FROM faixa_de_salario
GROUP BY faixa_salarial
ORDER BY faixa_salarial





-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos

with classif_veiculos as (
			SELECT
				vendas.visit_page_date,
				produtos.model_year,
				extract('year' from visit_page_date) - produtos.model_year::int as idade_veiculo,
				case
					when (extract('year' from visit_page_date) - produtos.model_year::integer) <= 2 then 'Novo'
					else 'Seminovo' end as classificacao
			FROM 
				sales.products as produtos
			LEFT JOIN
				sales.funnel as vendas
				ON produtos.product_id = vendas.product_id	)						
SELECT	
	classificacao,
	count(*)
FROM 
	classif_veiculos
GROUP BY classificacao


-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem

with tab_idade_veiculos as (
						SELECT
							pro.product_id,
							extract('year' from visit_page_date) - model_year::integer as idade_veiculo,
							case 
								when extract('year' from visit_page_date) - model_year::integer <= 2 then 'Até 2 anos'
								when extract('year' from visit_page_date) - model_year::integer <= 4 then 'De 2 a 4 anos'
								when extract('year' from visit_page_date) - model_year::integer <= 6 then 'De 4 a 6 anos'
								when extract('year' from visit_page_date) - model_year::integer <= 8 then 'De 6 a 8 anos'
								when extract('year' from visit_page_date) - model_year::integer <=10 then 'De 8 a 10 anos'
								else 'Acima de 10 anos' end as classif_idade_veiculos,
	
							case 
								when extract('year' from visit_page_date) - model_year::integer <= 2 then '1'
								when extract('year' from visit_page_date) - model_year::integer <= 4 then '2'
								when extract('year' from visit_page_date) - model_year::integer <= 6 then '3'
								when extract('year' from visit_page_date) - model_year::integer <= 8 then '4'
								when extract('year' from visit_page_date) - model_year::integer <=10 then '5'
								else '6' end as ordem
						FROM
							sales.products as pro
						LEFT JOIN	
							sales.funnel as vendas
							ON pro.product_id = vendas.product_id)

SELECT 
	classif_idade_veiculos AS "Idade do Veículo",
	count(*)/30580::float AS "Veículos Visitados",
	ordem
FROM 
	tab_idade_veiculos
GROUP BY classif_idade_veiculos, ordem
ORDER BY ordem



-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

SELECT	
	pro.brand,
	pro.model,
	count(vendas.visit_page_date)
FROM 
	sales.products as pro
LEFT JOIN
	sales.funnel as vendas	
	ON pro.product_id = vendas.product_id
GROUP BY pro.brand, pro.model
ORDER BY pro.brand,count(vendas.visit_page_date) DESC

