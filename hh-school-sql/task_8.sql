--
CREATE TABLE resume_history (
resume_id integer not null,
last_change_time timestamp not null,
old_title varchar(220),
new_title varchar(220)
);

CREATE OR REPLACE FUNCTION delete_resume() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
        	UPDATE resume SET active = False, visible = False WHERE resume_id = OLD.resume_id;
        	
            IF NOT FOUND THEN RETURN NULL; END IF;
            RETURN OLD;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_resume() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'UPDATE') THEN  	
        	INSERT INTO resume_history VALUES(NEW.resume_id, now(), OLD.title, NEW.title);
            IF NOT FOUND THEN RETURN NULL; END IF;
            RETURN NEW;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER func_delete_resume
BEFORE UPDATE ON resume FOR EACH ROW EXECUTE FUNCTION delete_resume();

CREATE TRIGGER func_update_resume
AFTER UPDATE ON resume FOR EACH ROW EXECUTE FUNCTION update_resume();

select * from resume_history;
select * from resume where init_id = 1;

UPDATE resume SET visible = True where init_id = 1;
DELETE FROM resume where resume.init_id=1;

INSERT INTO resume VALUES(100005, now(), 3, True, True, 'Title 1', null, '', now());
