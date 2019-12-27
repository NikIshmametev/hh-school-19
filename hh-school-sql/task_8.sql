-- Написать запрос, в котором по resume_id выводилась бы история изменения названия резюме в виде: (resume_id, last_change_time, old_title, new_title). Возможно выбрать одну из реализаций, если не можете выбрать, попросите вариант у лектора:
-- Создать столбец active в таблице резюме. Написать триггер который при любом изменении строки из таблицы (DELETE, UPDATE) пометит изменяемую запись в таблице как active = False, и при UPDATE создаст новую запись. Во всех запросах выше нужно будет учесть флаг active - то есть работать только с активными записями.
CREATE TABLE IF NOT EXISTS resume_history (
	resume_id int NOT NULL,
	creation_time timestamp NOT NULL,
    person_id integer DEFAULT 0 NOT NULL,    
    active boolean DEFAULT false NOT NULL,
    visible boolean DEFAULT true NOT NULL,
	title varchar(220) DEFAULT ''::varchar NOT NULL,
	init_id integer NOT NULL,
	last_change_time timestamp not null,
	new_title varchar(220)
);

CREATE OR REPLACE FUNCTION update_resume() RETURNS TRIGGER AS $$
    BEGIN
    IF TG_OP = 'UPDATE' THEN
       OLD.active = False;
       OLD.visible = False;
       INSERT INTO resume_history VALUES (OLD.*, NEW.title);
       
       NEW.last_change_time = now();
       RETURN NEW;
       
    ELSIF TG_OP = 'DELETE' THEN
    	INSERT INTO resume_history VALUES (OLD.*, null);
    	
    	OLD.active = False;
    	OLD.visible = False;
    	INSERT INTO resume VALUES (OLD.*);
    	RETURN OLD;
	END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER func_update_resume
AFTER UPDATE OR DELETE ON resume FOR EACH ROW EXECUTE FUNCTION update_resume();