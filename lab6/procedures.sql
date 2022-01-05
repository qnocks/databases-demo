CREATE OR REPLACE PROCEDURE add_payment (
    _amount decimal,
    _payment_date date,
    _owner_first_name varchar(50),
    _owner_second_name varchar(50),
    _contribution_name varchar(100),
    _contribution_price int,
    _contribution_date date
)
LANGUAGE plpgsql AS
$$
DECLARE
    payment_id_new int;
    contribution_id_new int;
    owner_id_new int;
BEGIN
    IF EXISTS(
        SELECT * FROM contribution
        WHERE contribution.name = _contribution_name AND contribution.price = _contribution_price)
        THEN
            SELECT c.id
            INTO contribution_id_new
            FROM contribution c
            WHERE c.name = _contribution_name AND c.price = _contribution_price;
        ELSE
            SELECT coalesce(max(c.id) + 1, 0)
            INTO contribution_id_new
            FROM contribution c;

            INSERT INTO contribution(id, name, description, price, contribution_date)
            VALUES (contribution_id_new, _contribution_name, null, _contribution_price, _contribution_date);
        END IF;
    IF EXISTS(SELECT * FROM owner WHERE owner.first_name = _owner_first_name AND owner.second_name = _owner_second_name)
        THEN
            SELECT o.id
            INTO owner_id_new
            FROM owner o
            WHERE o.first_name = _owner_first_name AND o.second_name = _owner_second_name;
    ELSE
        SELECT coalesce(max(o.id) + 1, 0)
        INTO owner_id_new
        FROM owner o;

        INSERT INTO owner(id, first_name, second_name, patronymic, birthdate, phone)
        VALUES (owner_id_new, _owner_first_name, _owner_second_name, null, null, null);
    END IF;
    SELECT coalesce(max(p.id) + 1, 0) INTO payment_id_new FROM payment p;
    INSERT INTO payment (id, amount, payment_date, owner_id, contribution_id)
    VALUES (payment_id_new, _amount, _payment_date, owner_id_new, contribution_id_new);
END;
$$;

-- CALL add_payment(777, '1998-10-02', 6, 4);

CALL add_payment(
    999,
    '2000-10-10',
    'ТЕСТ',
    'ТЕСТ',
    'Взноз ТЕСТ',
    999,
    '2000-10-10');

-- ===============================================================================
CREATE OR REPLACE PROCEDURE delete_payment (
    _payment_id int
)
LANGUAGE plpgsql AS
$$
DECLARE
    contribution_id_del int;
    owner_id_del int;
BEGIN
    SELECT payment.contribution_id
    INTO contribution_id_del
    FROM payment
    WHERE payment.id = _payment_id;

    SELECT p2.owner_id
    INTO owner_id_del
    FROM payment p2
    WHERE p2.id = _payment_id;

    DELETE FROM payment
    WHERE payment.id = _payment_id;

    IF NOT EXISTS(SELECT * FROM payment p WHERE p.contribution_id = contribution_id_del) THEN
        DELETE FROM contribution c WHERE c.id = contribution_id_del;
    END IF;
END;
$$;

CALL delete_payment(4);

-- ===============================================================================
CREATE OR REPLACE PROCEDURE delete_cascade_contribution (
    _contribution_id int
)
LANGUAGE plpgsql AS
$$
BEGIN
    DELETE FROM payment
    WHERE payment.contribution_id = _contribution_id;
--           (SELECT c.id FROM contribution c WHERE c.id = _contribution_id);
    DELETE FROM contribution
    WHERE id = _contribution_id;
END;
$$;

CALL delete_cascade_contribution(5);

-- ===============================================================================
CREATE OR REPLACE FUNCTION count_contributions ()
RETURNS int
LANGUAGE plpgsql AS
$$
DECLARE
    cnt int;
BEGIN
    SELECT coalesce(count(c.id), 0)
    INTO cnt
    FROM contribution c;
    RETURN cnt;
END;
$$;

SELECT * FROM count_contributions();

-- ===============================================================================
-- CREATE OR REPLACE FUNCTION get_statistics()
-- LANGUAGE plpgsql AS
-- $$
-- BEGIN
--     CREATE TEMPORARY TABLE IF NOT EXISTS payment_stat (
--         id serial PRIMARY KEY,
--         owner_id int,
--         contribution_id int,
--         payment_cnt int,
--         amount_avg float8
--     );
--
--     INSERT INTO payment_stat (owner_id, payment_cnt)
--     SELECT o.id, count(p.id)
--     FROM owner o
--         JOIN payment p
--             ON o.id = p.owner_id
--     GROUP BY o.id;
--
--     UPDATE payment_stat SET payment_cnt =(SELECT count(p.id) FROM payment p),
--                             amount_avg = (SELECT avg(p.amount) FROM payment p);
--
--     PERFORM *
--     FROM payment_stat;
--
--     DROP TABLE payment_stat;
-- END;
-- $$;

-- ===============================================================================
DROP FUNCTION get_statistics();

SELECT * FROM get_statistics();

-- =====================================================================================================
CREATE OR REPLACE FUNCTION get_statistics()
RETURNS TABLE (
    id int,
    owner_surname varchar(50),
    contribution_name varchar(50),
    payment_cnt int,
    amount float8
)
LANGUAGE plpgsql AS
$$
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS payment_stat (
        id serial PRIMARY KEY,
        owner_surname varchar(50),
        contribution_name varchar(50),
        payment_cnt int,
        amount float8
    );

    INSERT INTO payment_stat (owner_surname, payment_cnt, contribution_name, amount)
    SELECT o.second_name, count(p.id), c.name, sum(p.amount)
    FROM payment p
        JOIN contribution c on c.id = p.contribution_id
        JOIN owner o on o.id = p.owner_id
    GROUP BY o.second_name, c.name;

    RETURN QUERY
        SELECT * FROM payment_stat;

    DROP TABLE payment_stat;
END;
$$;

SELECT * FROM get_statistics();