-- Для каждого резюме вывести его идентификатор, массив из его специализаций, а также самую частую специализацию у вакансий, на которые он откликался (NULL если он не откликался ни на одну вакансию). Для агрегации специализаций в массив воспользоваться функцией array_agg.
WITH 
all_vacancy_spec_for_resume AS (
	SELECT resume_id, specialization_id, count(specialization_id) FROM response 
		LEFT JOIN vacancy USING (vacancy_id)
		LEFT JOIN vacancy_body_specialization USING (vacancy_body_id)
		GROUP BY resume_id, specialization_id),
max_vacancy_spec_for_resume AS (
	SELECT resume_id, MAX(count) FROM all_vacancy_spec_for_resume GROUP BY resume_id),
most_frequent_vacancy_spec_for_resume AS (
	SELECT resume_id, ARRAY_AGG(specialization_id) AS vacancy_spec FROM (
		SELECT * FROM max_vacancy_spec_for_resume t1 LEFT JOIN all_vacancy_spec_for_resume t2 USING (resume_id)
		WHERE t2.count = t1.max) T
	GROUP BY resume_id),
all_resume_spec AS (
	SELECT resume_id, ARRAY_AGG(specialization_id ORDER BY specialization_id) AS resume_spec FROM resume 
	LEFT JOIN resume_specialization USING (resume_id)
	GROUP BY resume_id)

SELECT resume_id, t1.resume_spec, t2.vacancy_spec FROM resume 
	LEFT JOIN all_resume_spec t1 USING (resume_id)
	LEFT JOIN most_frequent_vacancy_spec_for_resume t2 USING (resume_id);
