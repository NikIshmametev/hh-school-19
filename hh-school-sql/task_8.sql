-- Написать запрос, в котором по resume_id выводилась бы история изменения названия резюме в виде: (resume_id, last_change_time, old_title, new_title). Возможно выбрать одну из реализаций, если не можете выбрать, попросите вариант у лектора:
-- Создать столбец active в таблице резюме. Написать триггер который при любом изменении строки из таблицы (DELETE, UPDATE) пометит изменяемую запись в таблице как active = False, и при UPDATE создаст новую запись. Во всех запросах выше нужно будет учесть флаг active - то есть работать только с активными записями.

CREATE TABLE IF NOT EXISTS resume_history (
	resume_id bigint not null,
	last_change_time timestamp not null,
	old_title varchar(220),
	new_title varchar(220)
);

CREATE OR REPLACE FUNCTION update_resume() RETURNS TRIGGER AS $$
    BEGIN
    IF TG_OP = 'UPDATE' THEN
       INSERT INTO resume_history(resume_id, last_change_time, old_title, new_title)
       VALUES (OLD.resume_id, now(), OLD.title, NEW.title);
       OLD.resume_id = (SELECT MAX(resume_id)+1 FROM resume);
       OLD.active = False;
       OLD.visible = False;
       INSERT INTO resume VALUES (OLD.*);
       RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
    	INSERT INTO resume_history(resume_id, last_change_time, old_title, new_title)
    	VALUES (OLD.resume_id, now(), OLD.title, null);
    	OLD.active = False;
    	OLD.visible = False;
    	INSERT INTO resume VALUES (OLD.*);
    	RETURN OLD;
	END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER func_update_resume
AFTER UPDATE OR DELETE ON resume FOR EACH ROW EXECUTE FUNCTION update_resume();

SELECT * FROM resume_history;