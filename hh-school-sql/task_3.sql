-- Вывести среднюю величину предлагаемой зарплаты по каждому региону (area_id): средняя нижняя граница, средняя верхняя граница и средняя средних. Нужно учесть поле compensation_gross, а также возможность отсутствия значения в обоих или одном из полей со значениями зарпаты.


WITH net_salaries AS (
SELECT
	area_id,
	AVG(CASE WHEN compensation_gross IS TRUE THEN compensation_from*0.87 ELSE compensation_from END) AS avg_from,
	AVG(CASE WHEN compensation_gross IS TRUE THEN compensation_to*0.87 ELSE compensation_from END) AS avg_to
FROM (SELECT * FROM vacancy_body left join vacancy USING (vacancy_body_id) WHERE active=True) AS T
GROUP BY area_id ORDER BY area_id
)

SELECT area_id, avg_from, avg_to,
	   coalesce((avg_from+avg_to)/2, avg_from, avg_to) AS avg_mid
FROM net_salaries;
