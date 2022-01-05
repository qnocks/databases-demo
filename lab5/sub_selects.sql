-- Один из запросов на максимум/минимум реализовать с помощью директивы all
--
-- Запрос на «все» (реляционное деление) реализовать с помощью 2 not exists
--
-- Запросы на разность реализовать в 3 вариантах: Not in, except (MySQL не поддерживает,
-- поэтому только синтаксис), с использованием левого/правого соединения

-- 4. Владелец (владельцы) участка максимальной площади
------ с ALL
SELECT o.first_name,
       o.second_name,
       o.patronymic,
       o.birthdate,
       o.phone
FROM owner o
    JOIN owner_garden og
        ON og.owner_id = o.id
    JOIN garden g
        ON og.garden_id = g.id
WHERE g.area >= All (
    SELECT area
    FROM garden
);

------ без ALL
SELECT o.first_name,
       o.second_name,
       o.patronymic,
       o.birthdate,
       o.phone
FROM owner o
         JOIN owner_garden og
                   ON og.owner_id = o.id
         JOIN garden g
                   ON og.garden_id = g.id
WHERE g.area = (
    SELECT MAX(area)
    FROM garden
);

-- 5. Владельцы участков с максимальным числом типов построек
SELECT o.first_name,
       o.second_name,
       o.phone
FROM owner o
    JOIN owner_garden og
        ON o.id = og.owner_id
    JOIN garden g
        ON g.id = og.garden_id
    JOIN building b
        ON g.id = b.garden_id
    JOIN building_type bt
        ON bt.id = b.building_type_id
GROUP BY o.id,
         g.id
HAVING COUNT(DISTINCT bt.id) = (
    SELECT MAX(q.cnt)
    FROM (
        SELECT COUNT(DISTINCT bt2.id) AS cnt
        FROM owner o2
            JOIN owner_garden og2
                ON o2.id = og2.owner_id
            JOIN garden g2
                ON g2.id = og2.garden_id
            JOIN building b2
                ON og2.garden_id = b2.garden_id
            JOIN building_type bt2 on bt2.id = b2.building_type_id
            GROUP BY o2.id,
                     g2.id
    ) as q
);

-- 6. Владельцы, оплатившие все типы взносов, не содержащие в названии букву «К»
SELECT DISTINCT o.first_name,
                o.second_name,
                o.phone
FROM owner o
WHERE NOT EXISTS (
        SELECT *
        FROM contribution c
        WHERE c.name NOT LIKE '%к%' AND NOT EXISTS (
                SELECT *
                FROM owner o2
                    JOIN payment p2
                        ON o2.id = p2.owner_id
                    WHERE o.id = o2.id AND c.id = p2.contribution_id
        )
);

SELECT o.first_name,
       o.second_name,
       o.phone
FROM owner o
WHERE NOT EXISTS (
    SELECT *
    FROM contribution c
    WHERE c.name NOT LIKE '%к%' AND NOT EXISTS (
        SELECT *
        FROM owner o2, payment p
        WHERE o.id = p.owner_id AND p.contribution_id = c.id
    )
);

-- 7. Участки, на которых нет бань, но есть туалеты
------ NOT IN
SELECT g.number,
       g.cost,
       g.area
FROM garden g
    JOIN building b
        ON g.id = b.garden_id
    JOIN building_type bt
        ON bt.id = b.building_type_id
WHERE bt.name = 'Туалет' AND g.id NOT IN (
    SELECT g2.id
    FROM garden g2
        JOIN building b
            ON g2.id = b.garden_id
        JOIN building_type bt
            ON bt.id = b.building_type_id
    WHERE bt.name = 'Баня'
);

------ EXCEPT
SELECT g.number,
       g.cost,
       g.area
FROM garden g
    JOIN building b
        ON g.id = b.garden_id
    JOIN building_type bt
        ON bt.id = b.building_type_id
    WHERE bt.name = 'Туалет'
EXCEPT (
    SELECT g2.number,
           g2.cost,
           g2.area
    FROM garden g2
        JOIN building b
            ON g2.id = b.garden_id
        JOIN building_type bt
            ON bt.id = b.building_type_id
        WHERE bt.name = 'Баня'
);

----- с использованием левого/правого соединения
SELECT g.number,
       g.cost,
       g.area
FROM garden g
    JOIN building b
        ON g.id = b.garden_id
    JOIN building_type bt
        ON bt.id = b.building_type_id
WHERE bt.name = 'Туалет' AND 0 = (
    SELECT COUNT(*) FROM garden g2
        LEFT JOIN building b
            ON g2.id = b.garden_id
        LEFT JOIN building_type bt
            ON bt.id = b.building_type_id
        WHERE bt.name = 'Баня' AND g.id = g2.id
);

SELECT g.number,
       g.cost,
       g.area
FROM garden g
    JOIN building b
        ON g.id = b.garden_id
    JOIN building_type bt
        ON bt.id = b.building_type_id
         LEFT JOIN (
             SELECT g2.id
             FROM garden g2
                JOIN building b2
                    ON g2.id = b2.garden_id
                JOIN building_type bt2
                    ON b2.building_type_id = bt2.id
WHERE bt2.name = 'Баня'
) q ON g.id = q.id
WHERE bt.name = 'Туалет' AND q.id IS NULL;
