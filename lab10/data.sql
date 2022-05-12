TRUNCATE TABLE building CASCADE ;
TRUNCATE TABLE building_type CASCADE ;
TRUNCATE TABLE contribution CASCADE ;
TRUNCATE TABLE facility CASCADE ;
TRUNCATE TABLE garden CASCADE ;
TRUNCATE TABLE owner CASCADE ;
TRUNCATE TABLE owner_garden CASCADE ;
TRUNCATE TABLE payment CASCADE ;

-- Insert
INSERT INTO building_type(id, name, is_public)
VALUES (1, 'building_type1', true),
       (2, 'building_type2', true),
       (3, 'building_type3', false);

INSERT INTO garden(id, number, area, cost)
VALUES (1, (1, 'K'), 1000, 1000000),
       (2, (2, 'K'), 2000, 2000000),
       (3, (3, 'K'), 3000, 3000000),
       (4, (2, null), 4000, 4000000);

INSERT INTO building(id, garden_id, building_type_id)
VALUES (1, 1, 1),
       (2, 2, 2),
       (3, 3, 3);

INSERT INTO facility(id, garden_id, building_type_id, name, area)
VALUES (1, 1, 1, 'facility1', 1000),
       (2, 1, 2, 'facility2', 2000),
       (3, 2, 3, 'facility3', 3000),
       (4, 2, 3, 'facility4', 4000);

INSERT INTO owner(id, first_name, second_name, patronymic, birthdate, phone)
VALUES (1, 'first_name1', 'second_name1', 'patronymic1', '2022-04-10', '89059721226'),
       (2, 'first_name2', 'second_name2', 'patronymic2', '2020-03-08', '89059799226'),
       (3, 'first_name3', 'second_name3', 'patronymic3', '2021-05-11', '89119722226');

INSERT INTO owner_garden(id, owner_id, garden_id)
VALUES (1, 1, 2),
       (2, 2, 2),
       (3, 3, 2);

INSERT INTO contribution(id, name, description, price, contribution_date)
VALUES (1, 'contribution_name1', 'contribution_name1', 1000, '2020-04-10'),
       (2, 'contribution_name2', 'contribution_name2', 2000, '2020-03-10'),
       (3, 'contribution_name3', 'contribution_name3', 3000, '2020-02-10');

INSERT INTO payment(id, amount, payment_date, owner_id, contribution_id)
VALUES (1, 1000, '2020-02-02', 1, 1),
       (2, 2000, '2020-03-03', 2, 2),
       (3, 3000, '2020-03-03', 3, 3);

-- Select
SELECT *
FROM ONLY building b
WHERE b.garden_id = 2;

SELECT *
FROM building b
WHERE b.garden_id = 2;

SELECT *
FROM facility f
where f.garden_id = 2;

-- SELECT *
-- FROM building
--          join building_type bt ON bt.id = building.building_type_id
-- where bt.name = 'building_type2';

-- Operator
CREATE OR REPLACE FUNCTION find_building_type(VARCHAR,VARCHAR)
    RETURNS SETOF RECORD AS
$$
    SELECT (g.number).name,
           (g.number).line
    FROM garden g
             JOIN building b
                  ON g.id = b.garden_id
             JOIN building_type bt
                  ON bt.id = b.building_type_id
    WHERE ((g.number).name = $1) AND (bt.name = $2);
$$ IMMUTABLE
    LANGUAGE sql;

CREATE OPERATOR ? (
    -- number
    LEFTARG = VARCHAR,
    -- building type
    RIGHTARG = VARCHAR,
    function = find_building_type,
    commutator = ?
);

SELECT 'K'::varchar? 'building_type1'::varchar;

-- Aggregate function
CREATE OR REPLACE FUNCTION min_garden_number(garden_number, garden_number)
    RETURNS garden_number
    LANGUAGE plpgsql AS
$$
BEGIN
    IF $1 IS NULL THEN
        RETURN $2;
    ELSEIF $2 IS NULL THEN
        RETURN $1;
    ELSEIF ($1.line < $2.line) THEN
        RETURN $1;
    ELSEIF ($1.line = $2.line AND $1.name < $2.name) THEN
        RETURN $1;
    ELSEIF ($1.line = $2.line AND $2.name < $1.name) THEN
        RETURN $2;
    ELSE
        RETURN $1;
    END IF;
END
$$;

CREATE AGGREGATE min(garden_number) (
    sfunc = min_garden_number,
    stype = garden_number
);

SELECT min(number) FROM garden;
select *
from garden;
