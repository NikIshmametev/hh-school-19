SELECT count(*) FROM vacancy;

SELECT 
    (SELECT string_agg(
        substr('    abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
			(random() * 10)::integer + 1, 1), '') 
    FROM generate_series(1, 1 + (random() * 250 + i % 10)::integer))
FROM generate_series(1, 10000) AS g(i);

SELECT * FROM generate_series(1, 10000) AS g(i);

SELECT count(*) FROM vacancy WHERE vacancy.expire_time>vacancy.creation_time;
SELECT count(*) FROM vacancy_body;
SELECT * FROM vacancy_body LIMIT(10);
SELECT count(*) FROM response LIMIT(10);
SELECT count( distinct response_id) FROM response;