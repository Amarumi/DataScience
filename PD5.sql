Będziemy rozpartywać kampanie marketingowe (tabele m_lead, m_kampanie, m_lead_kampania)
Każdy lead może zostać wysłany w ramach kilku kampanii.
Zadanie:
Dla każdego leada wyznaczyć w ilu różnych rodzajach kampanni został wysłany, liczbę tą
nazywać będziemy dalej grupą kampanii.
Spożądzić zestawnienie, w którym będą następujace informacje:
Dla każdego roku i grupy kampanii wyliczyć udział procentowy grupy kampanii we wszystkich wysłanych
leadach w danym roku oraz zmianę procentową tej wartości rok do roku (YoY)
Uwaga! - należy usunać leady z niepoprawną datą wysłania

with kam_lead as
(select * from
  (select distinct
    w.id as id_lead,
    count(t.id) over (partition by w.id) as grupa_kampanii,
    date_part('year', w.data_wysylki) as lead_year
  from
    m_lead as w
  join m_lead_kampania a on a.id_lead = w.id
  join m_kampanie t on t.id = a.id_kampania
  where date_part('year', w.data_wysylki) < '2998'
  ) k
),

lead_popr as
(select
  u.lead_year,
  u.grupa_kampanii,
  count(u.grupa_kampanii) / sum(count(u.grupa_kampanii)) over (partition by u.lead_year) as proc_rok
from
  kam_lead u
group by u.lead_year, u.grupa_kampanii
order by 1, 2 asc)

Select *,
      (proc_rok - lag(proc_rok) over (partition by grupa_kampanii order by lead_year))
      / (lag(proc_rok) over (partition by grupa_kampanii order by lead_year)) as YoY
from lead_popr
order by 1,2
