-- soal nomor 1

SELECT 
	uc.continent,
	COUNT(DISTINCT uc.company_id) AS total_company
FROM unicorn_companies uc 
GROUP BY 1
ORDER BY 2 DESC;

-- soal nomor 2

SELECT 
	uc.country,
	COUNT(DISTINCT uc.company_id) AS total_company
FROM unicorn_companies uc 
GROUP BY 1
HAVING COUNT(DISTINCT uc.company_id) > 100
ORDER BY 2 DESC;

-- soal nomor 3

SELECT
	DISTINCT ui.industry,
	SUM(uf.funding) AS total_funding,
	ROUND(AVG(uf.valuation),2) AS avg_funding
FROM unicorn_industries ui 
INNER JOIN unicorn_funding uf 
	ON ui.company_id = uf.company_id 
GROUP BY 1
ORDER BY 2 DESC;

-- soal nomor 4

SELECT 
	COUNT(uc.company_id) AS total_company,
	EXTRACT(YEAR FROM ud.date_joined) AS year_joined
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id 
INNER JOIN unicorn_dates ud 
	ON uc.company_id = ud.company_id 
	AND ui.industry = 'Fintech'
	AND EXTRACT(YEAR FROM ud.date_joined) BETWEEN 2016 AND 2022
GROUP BY 2
ORDER BY 2 DESC;

-- soal nomor 5

SELECT 
	uc.company,
	uc.city,
	uc.country,
	uc.continent,
	ui.industry,
	uf.valuation
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id 
INNER JOIN unicorn_funding uf 
	ON uc.company_id = uf.company_id 
--WHERE uc.country = 'Indonesia'
ORDER BY 6 DESC;

-- soal nomor 6

SELECT 
	uc.company,
	uc.country,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded AS age_in_year
FROM unicorn_companies uc 
INNER JOIN unicorn_dates ud
	ON uc.company_id = ud.company_id 
ORDER BY 3 DESC;

--soal nomor 7

SELECT 
	uc.company,
	uc.country,
	EXTRACT(YEAR FROM ud.date_joined) - year_founded AS age_in_year
FROM unicorn_companies uc 
INNER JOIN unicorn_dates ud 
	ON uc.company_id = ud.company_id 
WHERE year_founded BETWEEN 1960 AND 2000
ORDER BY 3 DESC;

--soal nomor 8

SELECT
	COUNT(DISTINCT uf.company_id)
FROM unicorn_funding uf 
WHERE LOWER(uf.select_investors) LIKE '%venture%';

SELECT 
	COUNT(DISTINCT CASE WHEN LOWER(uf.select_investors) LIKE '%venture%' THEN uf.company_id END) AS venture_investor,
	COUNT(DISTINCT CASE WHEN LOWER(uf.select_investors) LIKE '%capital%' THEN uf.company_id END) AS capital_investor,
	COUNT(DISTINCT CASE WHEN LOWER(uf.select_investors) LIKE '%partner%' THEN uf.company_id END) AS partner_investor
FROM unicorn_funding uf;

-- soal nomor 9

SELECT 
	COUNT(DISTINCT CASE WHEN uc.continent = 'Asia' AND LOWER(ui.industry) LIKE '%logistic%' THEN uc.company_id END) AS logistic_asia,
	COUNT(DISTINCT CASE WHEN uc.country = 'Indonesia' AND LOWER(ui.industry) LIKE '%logistic%' THEN uc.company_id END) AS logistic_id
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id;

-- soal nomor 10

WITH top3 AS(
SELECT
	uc.country,
	COUNT (DISTINCT company_id) AS jumlah
FROM
	unicorn_companies uc
GROUP BY uc.country 
ORDER BY jumlah DESC
LIMIT 3
)
SELECT
	ui.industry,
	uc.country,
	COUNT (DISTINCT uc.company_id) AS jumlah_company
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id
WHERE uc.continent = 'Asia'
AND uc.country NOT IN (
	SELECT
		DISTINCT country 
	FROM top3
)
GROUP BY 1,2
ORDER BY 3 DESC, 1, 2;

-- soal nomor 11

SELECT
	DISTINCT ui.industry
FROM unicorn_industries ui 
WHERE ui.industry NOT IN(
	SELECT 
	DISTINCT ui2.industry
	FROM unicorn_companies uc 
	INNER JOIN unicorn_industries ui2 
	ON uc.company_id = ui2.company_id 
	WHERE uc.country = 'India'
);

-- soal noomor 12

WITH top_3 AS(
SELECT 
	ui.industry,
	COUNT (DISTINCT ui.company_id)
FROM unicorn_industries ui 
INNER JOIN unicorn_dates ud 
ON ui.company_id = ud.company_id 
WHERE EXTRACT (YEAR FROM ud.date_joined) IN (2019,2020,2021)
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 3
),
yearly_rank AS ( 
SELECT
	ui2.industry,
	EXTRACT(YEAR FROM ud2.date_joined) AS year_joined,
	COUNT(DISTINCT ui2.company_id) AS total_company,
	ROUND(AVG(uf.valuation)/1000000000,2) as avg_valuation_billion
FROM unicorn_industries ui2
INNER JOIN unicorn_dates ud2 
ON ui2.company_id = ud2.company_id 
INNER JOIN unicorn_funding uf 
ON ui2.company_id = uf.company_id 
GROUP BY 1,2
)
SELECT
	y.* /*,
	SUM(total_company) OVER (PARTITION BY y.industry) total_per_industry*/
FROM yearly_rank y
INNER JOIN top_3 t
	ON y.industry = t.industry
WHERE year_joined IN (2019,2020,2021)
ORDER BY /*5 DESC,*/ 1, 2 DESC;
