with sall as
  (Select distinct str_all, count(name) over (partition by str_all) as cnt_all
  from
    (select distinct name, CONCAT(sex,sport,year) as str_all
    from athlete_events
    group by name, sex, sport, year
    ) a
  order by 1
  ),

snull as
  (Select distinct str_null, count(name) over (partition by str_null) as count_null
  from
    (select distinct name, CONCAT(sex,sport,year) as str_null
    from athlete_events
    where height is null or weight is null
    ) b
  order by 1
  ),

sclear as
  (Select str_all as str_clean
  from
    (Select str_all, cnt_all, count_null,
      COALESCE(count_null, 0) as cnt_null,
      case when (cnt_all / 2) > COALESCE(count_null, 0) then True else False end as is_true1,
      case when (cnt_all - COALESCE(count_null, 0)) >= 10 then True else False end as is_true2
    from sall
    left join snull on snull.str_null = sall.str_all
    ) c
  where is_true1 is true and is_true2 is true
  ),

smed as
  (select
      CONCAT(sex,sport,year) as str_med,
      percentile_cont(0.5) within group (order by height) as median_h,
      percentile_cont(0.5) within group (order by weight) as median_w
  from athlete_events
  where height is not null or weight is not null
  group by CONCAT(sex,sport,year)
  order by 1
  ),

final as
  (select
    str_clean as string,
    median_h,
    median_w
  from
    sclear
  left join smed on smed.str_med = sclear.str_clean
  ),

bmi as
  (Select *,
       weight_s/ ((height_s/100)^2) as bmi,
       avg(weight_s/ ((height_s/100)^2)) over (partition by string) as avg_bmi
  from
    (Select *,
      COALESCE(height, median_h) as height_s,
      COALESCE(weight, median_w) as weight_s
    from athlete_events
    join final on final.string = CONCAT(sex, sport, year)
    ) t
  where string is not null
  ),

--------------------------------------------------------------------------------------------

st_woman as
  (Select sport, sex, stddev(avg_bmi) as st_woman
  from bmi
  where sex like 'F'
  group by sex, sport
  ORDER BY 3 DESC
  limit 1
  ),

st_men as
 (Select sport, sex, stddev(avg_bmi) as st_men
 from bmi
 where sex like 'M'
 group by sex, sport
 ORDER BY 3 DESC
 limit 1
 )

Select * from st_woman
  union
Select * from st_men
