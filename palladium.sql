WITH MoM AS (
SELECT *, (avg_zamkniecie - lag(avg_zamkniecie) over ()) / lag(avg_zamkniecie) over () as MoM
FROM (SELECT to_char(data, 'YYYY') as rok,
       to_char(data, 'MM') as miesiac,
       avg(zamkniecie) as avg_zamkniecie
       FROM xpd
       GROUP BY to_char(data, 'YYYY'), to_char(data, 'MM')
       ORDER BY 1, 2
       ) m
),

nowe AS (
SELECT to_char(data, 'YYYY') as rok,
       to_char(data, 'MM') as miesiac
FROM (SELECT generate_series('2016-01-01', '2019-12-31', INTERVAL '1 month')::date as data
      ) d
),

wspolne AS (
SELECT nowe.rok as rok,
       nowe.miesiac as miesiac,
       mom.avg_zamkniecie as cena,
       avg(mom.mom) over () as wspl_trendu
       FROM nowe
         LEFT JOIN mom on mom.rok = nowe.rok and mom.miesiac = nowe.miesiac
ORDER BY 1, 2
)

SELECT rok,
       miesiac,
       COALESCE (cena, lag(cena, count) over ()) * (1 + wspl_trendu) ^ count
FROM (SELECT *,
       sum(case when cena is not null then 0 else 1 end) over (order by rok, miesiac)::integer as count
      FROM wspolne
      GROUP BY rok, miesiac, cena, wspl_trendu
      ORDER BY 1, 2
      ) m