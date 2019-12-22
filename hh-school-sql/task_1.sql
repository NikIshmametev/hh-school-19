CREATE TABLE vacancy_body (
    vacancy_body_id serial PRIMARY KEY,
    company_name varchar(150) DEFAULT ''::varchar NOT NULL,
    name varchar(220) DEFAULT ''::varchar NOT NULL,
    text text,
    area_id integer,
    address_id integer,
    work_experience integer DEFAULT 0 NOT NULL,
    compensation_from bigint DEFAULT 0,
    compensation_to bigint DEFAULT 0,
    test_solution_required boolean DEFAULT false NOT NULL,
    work_schedule_type integer DEFAULT 0 NOT NULL,
    employment_type integer DEFAULT 0 NOT NULL,
    compensation_gross boolean,
    driver_license_types varchar(5)[],
    CONSTRAINT vacancy_body_employment_type_validate CHECK ((employment_type = ANY (ARRAY[0, 1, 2, 3, 4]))),
    CONSTRAINT vacancy_body_work_schedule_type_validate CHECK ((work_schedule_type = ANY (ARRAY[0, 1, 2, 3, 4])))
);

CREATE TABLE vacancy (
    vacancy_id serial,
    creation_time timestamp NOT NULL,
    expire_time timestamp NOT NULL,
    employer_id integer DEFAULT 0 NOT NULL,    
    active boolean DEFAULT false NOT NULL,
    visible boolean DEFAULT true NOT NULL,
    vacancy_body_id integer REFERENCES vacancy_body,
	PRIMARY KEY (vacancy_id, vacancy_body_id),
	CHECK (creation_time < expire_time)
);

CREATE TABLE vacancy_body_specialization (
    vacancy_body_specialization_id serial,
    vacancy_body_id integer DEFAULT 0 NOT NULL REFERENCES vacancy_body,
    specialization_id integer DEFAULT 0 NOT NULL,
    UNIQUE (vacancy_body_id, specialization_id)
);

CREATE TABLE resume (
	resume_id serial PRIMARY KEY,
	creation_time timestamp NOT NULL,
    person_id integer DEFAULT 0 NOT NULL,    
    active boolean DEFAULT false NOT NULL,
    visible boolean DEFAULT true NOT NULL,
	title varchar(220) DEFAULT ''::varchar NOT NULL,
	init_id integer NOT NULL,
	old_title varchar(220),
	last_change_time timestamp
);

CREATE TABLE resume_specialization (
    resume_specialization_id serial,
    resume_id integer DEFAULT 0 NOT NULL REFERENCES resume,
    specialization_id integer DEFAULT 0 NOT NULL,
    UNIQUE (resume_id, specialization_id)
);

CREATE TABLE response (
	response_id serial,
	resume_id integer NOT NULL,
	vacancy_id integer NOT NULL,
	response_time timestamp NOT NULL,
	UNIQUE (resume_id, vacancy_id)
);

