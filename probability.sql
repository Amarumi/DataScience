--Zadanie:
--Rozpatrywać b�dzimy wnioski od roku 2016, kt�rych kwota rekompensaty jest niższa,
-- niż średnia kwota dla danego powodu operatora.
--Dla ka�dego roku wybrać lotnisko przylotu, kt�re w danym roku ma najwi�cej takich wniosków.
--Ponadto wyliczyć jakie jest prawdopodobieństwo tego, że spośród 3 losowo wybranych takich wniosków
-- z danego roku, 2 będą własnie z tego lotniska.
--Uwaga!! należy wykluczyć wnioski, dla których identyfikator podróży jest niepoprawny i zawiera "----"

with moje_dane as
  (Select distinct
    rok,
    lotnisko,
    count (id) as il_rok_lotnisko,
    rank() over (partition by rok order by count (id) desc) as rank
  from
    (Select distinct w.id,
                    to_char (w.data_utworzenia, 'YYYY') as rok,
                    case when w.kwota_rekompensaty < avg(w.kwota_rekompensaty) over (partition by w.powod_operatora)
                    then t2.kod_przyjazdu end as lotnisko
    from wnioski w
                    join podroze t on t.id_wniosku = w.id
                    join szczegoly_podrozy t2 on t2.id_podrozy = t.id
                                              and to_char (w.data_utworzenia, 'YYYY') >= '2016'
                                              and t2.identyfikator_podrozy not like '%----%'
    ) k
  where lotnisko is not null
  group by rok, lotnisko
  order by 4, 1 desc),

podsumowanie as
  (Select *,
    sum(il_rok_lotnisko) over (partition by rok) as il_rok
  from moje_dane
  )

Select *,
  ((il_rok_lotnisko / il_rok) * ((il_rok_lotnisko -1) / (il_rok -1)) * ((il_rok-il_rok_lotnisko) / (il_rok -2)))
   +
  ((il_rok_lotnisko / il_rok) * ((il_rok-il_rok_lotnisko) / (il_rok -1)) * ((il_rok_lotnisko -1) / (il_rok -2)))
   +
  (((il_rok-il_rok_lotnisko) / il_rok) * (il_rok_lotnisko / (il_rok -1)) * ((il_rok_lotnisko -1) / (il_rok -2)))
  as P
from podsumowanie
where rank = 1