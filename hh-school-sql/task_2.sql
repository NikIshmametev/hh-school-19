-- 10000 вакансий, 100000 резюме и 50000 откликов
-- Заполним vacancy_body
INSERT INTO vacancy_body(
    company_name, name, text, area_id, address_id, work_experience, compensation_from, 
    test_solution_required, work_schedule_type, employment_type, compensation_gross
)
SELECT 
    (SELECT string_agg(
        substr('      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
			(random() * 77)::integer + 1, 1), '') 
    FROM generate_series(1, 1 + (random() * 30 + i % 10)::integer)) AS company_name,

    (SELECT string_agg(
        substr('      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
			   (random() * 77)::integer + 1, 1), '') 
    FROM generate_series(1, 1 + (random() * 25 + i % 10)::integer)) AS name,

    (SELECT string_agg(
        substr('      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
			   (random() * 77)::integer + 1, 1), '') 
    FROM generate_series(1, 1 + (random() * 50 + i % 10)::integer)) AS text,

    (random() * 100)::int AS area_id,
    (random() * 50000)::int AS address_id,
    (random() * 10)::int AS work_experience,
    25000 + (random() * 150000)::int AS compensation_from,
    (random() > 0.5) AS test_solution_required,
    floor(random() * 4)::int AS work_schedule_type,
    floor(random() * 4)::int AS employment_type,
    (random() > 0.5) AS compensation_gross
FROM generate_series(1, 10000) AS g(i);
---- Обновим верхнюю границу зарплаты
UPDATE vacancy_body SET compensation_to = compensation_from + (random() * 150000)::int;

-- Заполним vacancy
INSERT INTO vacancy (vacancy_body_id, creation_time, expire_time, employer_id, active, visible)
SELECT
	(SELECT vacancy_body_id FROM vacancy_body WHERE vacancy_body_id=i) AS vacancy_body_id,
    now() - 360 * 24 * 3600 * (1+3*random()) * '1 second'::interval AS creation_time,
    now() AS expire_time,
    (random() * 1000)::int AS employer_id,
    (random() > 0.5) AS active,
    (random() > 0.5) AS visible
FROM generate_series(1, 10000) AS g(i);
---- Обновим время экспирации вакансии
UPDATE vacancy SET expire_time =  creation_time + 360 * 24 * 3600 *random() * '1 second'::interval;

-- Заполним resume
INSERT INTO resume (creation_time, person_id, active, visible, title, init_id, old_title)
SELECT
    now()-360 * 24 * 3600*(1+3*random()) * '1 second'::interval AS creation_time,
    (random() * 100000)::int AS person_id,
    (random() > 0.5) AS active,
    (random() > 0.5) AS visible,
	(SELECT string_agg(
		substr('      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
			   (random() * 77)::integer + 1, 1), '') 
    FROM generate_series(1, 1 + (random() * 50 + i % 10)::integer)) AS title,
    (random() * 100000)::int AS init_id,
	(SELECT string_agg(
		substr('      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
			   (random() * 77)::integer + 1, 1), '') 
    FROM generate_series(1, 1 + (random() * 50 + i % 10)::integer)) AS old_title
FROM generate_series(1, 100000) AS g(i);
---- Обновим время последнего изменения
UPDATE resume 
SET last_change_time = CASE
	WHEN (random()>0.5) THEN creation_time
	ELSE creation_time + 360 * 24 * 3600 * random() *'1 second'::interval
END;

-- Заполним response
INSERT INTO response (response_time, vacancy_id, resume_id)
SELECT now() AS response_time, * FROM(
	SELECT distinct (random() * 10000)::int AS vacancy_id, (random() * 100000)::int AS resume_id
FROM generate_series(1, 100000) limit 50000) as T;
---- Обновим время отклика
UPDATE response 
SET response_time = creation_time + 90 * 24 * 3600*random()*'1 second'::interval 
FROM vacancy WHERE response.vacancy_id = vacancy.vacancy_id;

-- Заполним специализации vacancy_body
INSERT INTO vacancy_body_specialization (vacancy_body_id, specialization_id)
	SELECT distinct (1+9999*random())::int AS vacancy_body_id, (100*random())::int AS specialization_id
	FROM generate_series(1, 50000) limit 25000;

-- Заполним специализации resume
INSERT INTO resume_specialization (resume_id, specialization_id)
	SELECT distinct (1+99999*random())::int AS resume_id, (1000*random())::int AS specialization_id
	FROM generate_series(1, 500000) limit 300000;
