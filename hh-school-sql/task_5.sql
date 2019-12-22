--Вывести названия вакансий в алфавитном порядке, на которые было меньше 5 откликов за первую неделю после публикации вакансии. В случае, если на вакансию не было ни одного отклика она также должна быть выведена.
WITH vacancyReduced AS (SELECT vacancy_id, creation_time, active FROM vacancy),

responseForWeek AS (
	SELECT * FROM response T1 LEFT JOIN vacancyReduced T2 USING (vacancy_id)
 	WHERE response_time > creation_time AND AGE(response_time, creation_time) <= interval '1 week'
 	AND active = True),

responseCount AS (
	SELECT vacancy_id, COUNT(resume_id) FROM responseForWeek GROUP BY vacancy_id),

vacancyWithResponseForWeek AS (
	SELECT vacancy_id, CASE WHEN count is NULL then 0 else count end
	FROM vacancy LEFT JOIN responseCount USING (vacancy_id)),

vacancyName AS (
	SELECT vacancy_id, name FROM vacancy_body LEFT JOIN vacancy USING (vacancy_body_id))

SELECT vacancy_id, name from vacancyName AS T
	WHERE T.vacancy_id IN (SELECT vacancy_id FROM vacancyWithResponseForWeek WHERE count < 5)
 	ORDER BY name ASC;
