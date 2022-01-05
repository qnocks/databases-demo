select *
from owner;

-- many to many join example
SELECT * FROM owner o
        LEFT JOIN owner_garden og
                    ON og.owner_id = o.id
        LEFT JOIN garden g
                    ON og.garden_id = g.id;

-- 1. номера участков владельцев с отчеством, заканчивающимся на «ич»
SELECT DISTINCT(number)
FROM garden g
    JOIN owner_garden og
        ON g.id = og.garden_id
    JOIN owner o
        ON og.owner_id = o.id
WHERE o.patronymic LIKE '%ич';

-- 2. участки, на которых зарегистрировано более 1 типа постройки (без агрегатной функцией)
SELECT DISTINCT g.id,
                g.number,
                g.area,
                g.cost
FROM building b1
         JOIN building b2
              ON b1.building_type_id <> b2.building_type_id AND b1.garden_id = b2.garden_id
         JOIN garden g
              ON g.id = b1.garden_id;

-- 2. участки, на которых зарегистрировано более 1 типа постройки (c агрегатной функцией)
SELECT g.id,
       g.number,
       g.area,
       g.cost
FROM garden g
    LEFT JOIN building b
        ON g.id = b.garden_id
GROUP BY g.id,
         g.number
HAVING COUNT(g.id) > 1
ORDER BY g.id;

-- 3. тип взносов, которые пока никто не оплатил
SELECT c.id,
       c.name,
       c.description,
       c.price,
       c.contribution_date
FROM contribution c
    LEFT JOIN payment p ON c.id = p.contribution_id
WHERE p.owner_id IS NULL;