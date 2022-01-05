ALTER TABLE garden
ADD COLUMN IF NOT EXISTS building_count int DEFAULT 0;

-- ==============================================================

DROP FUNCTION count_buildings_after_insert();
DROP TRIGGER IF EXISTS count_buildings_after_insert ON building;

CREATE OR REPLACE FUNCTION count_buildings_after_insert()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    UPDATE garden SET building_count = building_count + 1
    WHERE id = new.garden_id;
    RETURN new;
END
$$;

CREATE TRIGGER count_buildings_after_insert
    AFTER INSERT ON building
    FOR EACH ROW
    EXECUTE PROCEDURE count_buildings_after_insert();

INSERT INTO building(id, garden_id, building_type_id)
VALUES (8, 1, 3);

-- ==============================================================

CREATE OR REPLACE FUNCTION count_buildings_after_update()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    UPDATE garden SET building_count = building_count - 1
    WHERE id = old.garden_id;
    UPDATE garden SET building_count = building_count + 1
    WHERE id = new.garden_id;
    RETURN new;
END
$$;

CREATE TRIGGER count_buildings_after_update
    AFTER UPDATE ON building
    FOR EACH ROW
    EXECUTE PROCEDURE count_buildings_after_update();

UPDATE building SET garden_id = 2
WHERE id = 8;

-- ==============================================================

CREATE OR REPLACE FUNCTION count_buildings_after_delete()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    UPDATE garden SET building_count = building_count - 1
    WHERE id = old.garden_id;
    RETURN new;
END
$$;

CREATE TRIGGER count_buildings_after_delete
    AFTER DELETE ON building
    FOR EACH ROW
EXECUTE PROCEDURE count_buildings_after_delete();

DELETE FROM building
WHERE id = 8;

-- ==============================================================

DROP TRIGGER before_delete_building_type ON building_type;
DROP FUNCTION before_delete_building_type;

CREATE OR REPLACE FUNCTION before_delete_building_type()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    DELETE FROM building
    WHERE building_type_id = old.id;
    RETURN old;
END
$$;

CREATE TRIGGER before_delete_building_type
    BEFORE DELETE ON building_type
    FOR EACH ROW
EXECUTE PROCEDURE before_delete_building_type();

INSERT INTO building_type
VALUES (4, 'Тестовое значение');

INSERT INTO building
VALUES (9, 1, 4);

DELETE FROM building_type
WHERE id = 4;

--- ============================================================
-- second before delete
-- CREATE OR REPLACE FUNCTION before_delete_contribution()
--     RETURNS TRIGGER
--     LANGUAGE plpgsql AS
-- $$
-- BEGIN
--     DELETE FROM payment
--     WHERE contribution_id = old.id;
--     RETURN new;
-- END
-- $$;
--
-- CREATE TRIGGER before_delete_contribution
--     BEFORE DELETE ON contribution
--     FOR EACH ROW
-- EXECUTE PROCEDURE before_delete_contribution();
--
-- INSERT INTO contribution
-- VALUES (5, 'Тест', 'Тест', 777, '2021-12-14');
--
-- INSERT INTO payment
-- VALUES (5, 9999, '2021-12-14', 1, 5);
--
-- DELETE FROM contribution
-- WHERE id = 5;

-- ==============================================================

DROP TABLE IF EXISTS backup_contribution;

DROP TRIGGER backup_update_contribution ON contribution;
DROP TRIGGER backup_delete_contribution ON contribution;

DROP FUNCTION backup_update_contribution;
DROP FUNCTION backup_delete_contribution;

CREATE TABLE IF NOT EXISTS backup_contribution (
    id serial PRIMARY KEY,
    row_id int NOT NULL,
    name varchar(100) NOT NULL,
    action varchar(20)
);

-- ==============================================================

CREATE OR REPLACE FUNCTION backup_update_contribution()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO backup_contribution(row_id, name, action)
    VALUES (old.id, old.name, 'update');
    RETURN new;
END
$$;

CREATE TRIGGER backup_update_contribution
    BEFORE UPDATE ON contribution
    FOR EACH ROW
EXECUTE PROCEDURE backup_update_contribution();

-- ==============================================================

CREATE OR REPLACE FUNCTION backup_delete_contribution()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO backup_contribution(row_id, name, action)
    VALUES (old.id, old.name, 'delete');
    RETURN old;
END
$$;

CREATE TRIGGER backup_delete_contribution
    BEFORE DELETE ON contribution
    FOR EACH ROW
EXECUTE PROCEDURE backup_delete_contribution();

-- ==============================================================

INSERT INTO contribution(id, name, description, price, contribution_date)
VALUES
       (5, 'Тестовое значение1', 'Тестовое значение1', 9999, '2021-12-14'),
       (6, 'Тестовое значение2', 'Тестовое значение2', 9999, '2021-12-14');

INSERT INTO payment
VALUES
       (5, 9999, '2021-12-14', 1, 5),
       (6, 9999, '2021-12-14', 1, 6);

DELETE FROM contribution
WHERE id = 5;

UPDATE contribution
SET name = 'Новое тестовое значение'
WHERE id = 6;

SELECT *
FROM backup_contribution;

-- ==============================================================

CREATE OR REPLACE FUNCTION valid_owner()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    new.first_name = concat(upper(left(new.first_name, 1)), lower(substring(new.first_name from 2)));
    new.second_name = concat(upper(left(new.second_name, 1)), lower(substring(new.second_name from 2)));
    RETURN new;
END
$$;

CREATE TRIGGER valid_owner
    BEFORE INSERT ON owner
    FOR EACH ROW
EXECUTE PROCEDURE valid_owner();

INSERT INTO owner(id, first_name, second_name)
VALUES (6, 'дЕНиС', 'лоДОЧкИн');

