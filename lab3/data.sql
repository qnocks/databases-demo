-- psql \! chcp 1251

--- INSERT
TRUNCATE TABLE owner CASCADE;
INSERT INTO owner (id, first_name, second_name, patronymic, birthdate, phone)
VALUES
       (1, 'Роман', 'Останин', 'Олегович', '2001-11-21', '89249653268'),
       (2, 'Дмитрий', 'Шаршев', 'Леонидович', '2000-06-13', '11111111'),
       (3, 'Виктор', 'Михайлов', 'Романович', '1998-04-15', '89242332658'),
       (4, 'Алина', 'Романова', 'Щербакова', '1996-10-10', '89445827272'),
       (5, 'Елена', 'Заболотнова', 'Эдуардовна', '2000-08-05', '89029830202');

TRUNCATE TABLE garden CASCADE;
INSERT INTO garden (id, number, area, cost)
VALUES
       (1, '245', 240, 400000),
       (2, '243', 120, 200000),
       (3, '102', 530, 1300000),
       (4, '175', 340, 1800000);

--- owner_garden
TRUNCATE TABLE owner_garden CASCADE;
INSERT INTO owner_garden (id, owner_id, garden_id)
VALUES
       (1, 1, 2),
       (2, 2, 2),
       (3, 2, 3),
       (4, 3, 1),
       (5, 5, 4);

TRUNCATE TABLE building_type CASCADE;
INSERT INTO building_type (id, name)
VALUES
       (1, 'Туалет'),
       (2, 'Баня'),
       (3, 'Дом'),
       (4, 'Дом на дереве');

--- building
TRUNCATE TABLE building CASCADE;
INSERT INTO building (id, garden_id, building_type_id)
VALUES
       (1, 1, 1),
       (2, 2, 2),
       (3, 3, 1),
       (4, 3, 2),
       (5, 3, 3),
       (6, 4, 1),
       (7, 4, 3);

TRUNCATE TABLE contribution CASCADE;
INSERT INTO contribution (id, name, description, price, contribution_date)
VALUES
       (1, 'Взнос на землю', 'описание взноса на землю', 10, '2020-10-09'),
       (2, 'Взнос на обработку от клеща', 'описание взноса на обработку', 24, '2021-05-04'),
       (3, 'Взнос на воду', 'описание взноса на воду', 4, '2019-06-15');
--       (4, 'Взнос на навоз', 'какой-то description', 12, '2019-12-30');

TRUNCATE TABLE payment CASCADE;
INSERT INTO payment (id, amount, payment_date, owner_id, contribution_id)
VALUES
       (1, 960, '2020-10-10', 3, 3),
       (2, 12720, '2021-11-12', 2, 1),
       (3, 5300, '2019-07-21', 2, 3);

--- UPDATE
UPDATE owner
SET phone = '89889211157'
WHERE first_name = 'Дмитрий' AND second_name = 'Шаршев' AND patronymic = 'Леонидович';

--- DELETE
DELETE FROM building_type
WHERE name = 'Дом на дереве';

--- =============================================================================

--- MERGE
-- Create source table
CREATE TABLE additional_building_type (
    id int PRIMARY KEY,
    name varchar(100) NOT NULL
);
-- Fill some data to it
INSERT INTO additional_building_type(id, name)
VALUES
       (1, 'Туалет'),
       (2, 'Колодец'),
       (3, 'Беседка');

MERGE INTO building_type AS t
USING additional_building_type AS s
ON (t.id = s.id)
-- When records are matched, update the records if there is any change
WHEN MATCHED AND t.name <> s.name
    THEN UPDATE SET t.name = s.name
-- When no records are matched, insert the incoming records from source table to target table
WHEN NOT MATCHED
    THEN INSERT (id, name) VALUES (s.id, s.name);

