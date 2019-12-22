-- Для каждого резюме вывести его идентификатор, массив из его специализаций, а также самую частую специализацию у вакансий, на которые он откликался (NULL если он не откликался ни на одну вакансию). Для агрегации специализаций в массив воспользоваться функцией array_agg.

-- Решение
-- Самым долгим запросом был запрос из 6-ой задачи, но там INDEX нельзя создать на CTE. После замены CTE на временные таблицы время уменьшилось кратно (в 4 раза), но добавление индекса ничего не дало.
-- Поэтому сделал задание на запросе из 4-ой задачки.

-- Самой тяжелой операцией является Sort по месяцам поля creation_time. До добавления индекса время выполнения запроса - 70ms, после того как добавил индекс на DATE_TRUNC('month', creation_time) - 0.1ms. При этом Seq Scan остался, но время его выполнения уменьшилось значительно.
EXPLAIN ANALYZE
CREATE TEMP TABLE resumeMonthly AS (
	SELECT DATE_TRUNC('month', creation_time) AS date, COUNT(resume_id) AS count FROM resume
	GROUP BY DATE_TRUNC('month', creation_time), active HAVING active = True
);
CREATE TEMP TABLE vacancyMonthly AS (
	SELECT DATE_TRUNC('month', creation_time) AS date, COUNT(vacancy_id) AS count FROM vacancy
	GROUP BY DATE_TRUNC('month', creation_time), active HAVING active = True
);

CREATE INDEX resume_index ON resume(DATE_TRUNC('month', creation_time));

SELECT 'Resume' AS Table, * FROM resumeMonthly WHERE count = (SELECT MAX(count) FROM resumeMonthly)
UNION
SELECT 'Vacancy' AS Table, * FROM vacancyMonthly WHERE count = (SELECT MAX(count) FROM vacancyMonthly)


