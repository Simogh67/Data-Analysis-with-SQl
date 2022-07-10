CREATE VIEW forestation AS
    SELECT 
        f.*,
        2.59 * l.total_area_sq_mi AS total_area_sq_km,
        r.region,
        (f.forest_area_sqkm / (2.59 * l.total_area_sq_mi)) * 100 AS forest_land_percent,
        r.income_group
    FROM
        forest_area f
           Full  JOIN
        land_area l ON f.country_code = l.country_code
            AND f.year = l.year
            Full JOIN
        regions r ON r.country_code = f.country_code

--1.a: 

SELECT 
    year, forest_area_sqkm AS sum_forest
FROM
    forestation
WHERE
    country_name = 'World'
        AND year IN ('1990')
ORDER BY 1

--1.b:

SELECT 
    year, forest_area_sqkm AS sum_forest
FROM
    forestation
WHERE
    country_name = 'World'
        AND year IN ('2016')
ORDER BY 1

--1.c-d:

 WITH t_1 AS (SELECT 
    year, forest_area_sqkm
FROM
    forestation f
WHERE
    country_name = 'World'
        AND year IN ('1990' , '2016')
ORDER BY 1) 
SELECT 
    (SELECT 
            forest_area_sqkm
        FROM
            t_1
        WHERE
            year = '1990') - (SELECT 
            forest_area_sqkm
        FROM
            t_1
        WHERE
            year = '2016') AS loss,
    (1 - (SELECT 
            forest_area_sqkm
        FROM
            t_1
        WHERE
            year = '2016') / (SELECT 
            forest_area_sqkm
        FROM
            t_1
        WHERE
            year = '1990')) * 100 AS percentage_loss
FROM
    t_1
LIMIT 1

--1.e:

SELECT 
    country_name,
    total_area_sq_km,
    ABS(total_area_sq_km - ((SELECT 
                    forest_area_sqkm
                FROM
                    forestation
                WHERE
                    country_name = 'World' AND year = '1990') - (SELECT 
                    forest_area_sqkm
                FROM
                    forestation
                WHERE
                    country_name = 'World' AND year = '2016'))) AS difference
FROM
    forestation
ORDER BY 3
LIMIT 1

--2a:

SELECT 
    region,
    year,
    (SUM(forest_area_sqkm) / SUM(total_area_sq_km)) * 100 AS forest_percent
FROM
    forestation
WHERE
    year = '2016'
GROUP BY 1 , 2
ORDER BY 3


--2b:

SELECT 
    region,
    year,
    (SUM(forest_area_sqkm) / SUM(total_area_sq_km)) * 100 AS forest_percent
FROM
    forestation
WHERE
    year = '1990'
GROUP BY 1 , 2
ORDER BY 3

--2c:

SELECT 
    *
FROM
    (SELECT 
        region,
            year,
            (SUM(forest_area_sqkm) / SUM(total_area_sq_km)) * 100 AS forest_percent
    FROM
        forestation
    WHERE
        year IN ('1990' , '2016')
    GROUP BY 1 , 2
    ORDER BY 3) p


--3a: 

WITH t_1 AS (SELECT 
    country_name, year, forest_area_sqkm, region
FROM
    forestation
WHERE
    country_name != 'World'
        AND year = '1990'
ORDER BY 1),
 t_2 AS (SELECT 
    country_name, year, forest_area_sqkm, region
FROM
    forestation
WHERE
    country_name != 'World'
        AND year = '2016'
ORDER BY 1)
SELECT 
    t_1.country_name,
    t_1.region,
    (t_2.forest_area_sqkm - t_1.forest_area_sqkm) AS inc,
    t_1.country_name,
    t_1.region,
    (t_2.forest_area_sqkm - t_1.forest_area_sqkm) / (t_1.forest_area_sqkm) * 100 AS inc_percent
FROM
    t_1
        JOIN
    t_2 ON t_1.country_name = t_2.country_name
WHERE
    (t_1.country_name , t_1.region,
        (t_2.forest_area_sqkm - t_1.forest_area_sqkm)) IS NOT NULL
ORDER BY 3 , 4 DESC

--3b:

WITH t_1 AS (SELECT 
    country_name, year, forest_area_sqkm, region
FROM
    forestation
WHERE
    country_name != 'World'
        AND year = '1990'
ORDER BY 1),
 t_2 AS (SELECT 
    country_name, year, forest_area_sqkm, region
FROM
    forestation
WHERE
    country_name != 'World'
        AND year = '2016'
ORDER BY 1)
SELECT 
    t_1.country_name,
    t_1.region,
    (t_2.forest_area_sqkm - t_1.forest_area_sqkm) / (t_1.forest_area_sqkm) * 100 AS lost
FROM
    t_1
        JOIN
    t_2 ON t_1.country_name = t_2.country_name
ORDER BY 3


--3c:

WITH t_1 as (SELECT 
    country_name,
    forest_area_sqkm,
    region,
    forest_land_percent,
    CASE
        WHEN forest_land_percent < 25 THEN '1'
        WHEN
            forest_land_percent < 50
                AND forest_land_percent >= 25
        THEN
            '2'
        WHEN
            forest_land_percent < 75
                AND forest_land_percent >= 50
        THEN
            '3'
        ELSE '4'
    END AS quartile
FROM
    forestation
WHERE
    forest_land_percent IS NOT NULL
        AND country_name != 'World'
        AND year = '2016'
ORDER BY 5)
SELECT 
    COUNT(quartile) AS quart_count, quartile
FROM
    t_1
GROUP BY 2


--3d:

WITH t_1 as (SELECT 
    country_name,
    forest_area_sqkm,
    region,
    forest_land_percent,
    CASE
        WHEN forest_land_percent < 25 THEN '1'
        WHEN
            forest_land_percent < 50
                AND forest_land_percent >= 25
        THEN
            '2'
        WHEN
            forest_land_percent < 75
                AND forest_land_percent >= 50
        THEN
            '3'
        ELSE '4'
    END AS quartile
FROM
    forestation
WHERE
    forest_land_percent IS NOT NULL
        AND country_name != 'World'
        AND year = '2016'
ORDER BY 5)
SELECT 
    country_name, forest_land_percent, region, quartile
FROM
    t_1
WHERE
    quartile = '4'
ORDER BY 2 DESC


--3e:

 SELECT count (*) FROM (SELECT 
    country_name, forest_land_percent
FROM
    forestation
WHERE
    forest_land_percent>
 (SELECT forest_land_percent 
 FROM
 forestation 
 WHERE
 country_name='United States' AND year='2016') AND year='2016') p
