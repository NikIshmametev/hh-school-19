--Вывести названия вакансий в алфавитном порядке, на которые было меньше 5 откликов за первую неделю после публикации вакансии. В случае, если на вакансию не было ни одного отклика она также должна быть выведена.
WITH 
responseForWeek AS (
	SELECT * FROM response LEFT JOIN 
	(SELECT vacancy_id, creation_time, active FROM vacancy) AS tmp USING (vacancy_id)
		WHERE response_time > creation_time AND AGE(response_time, creation_time) <= interval '1 week' AND active = True),

responseCount AS (
	SELECT vacancy_id, COUNT(resume_id) FROM responseForWeek GROUP BY vacancy_id),
		
vacancyWithResponseForWeek AS (
	SELECT vacancy_id, count FROM vacancy LEFT JOIN responseCount USING (vacancy_id) WHERE count < 5),

vacancyName AS (
	SELECT vacancy_id, name FROM vacancy_body INNER JOIN vacancy USING (vacancy_body_id))

SELECT vacancy_id, name from vacancyName INNER JOIN vacancyWithResponseForWeek USING (vacancy_id) ORDER BY name ASC;
