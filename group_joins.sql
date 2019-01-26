

--1) Za pomoca jednego zapytania (bez podzapytañ unionów itp ) stwórz spis wszystkich wniosków
--zawierajacy id_wniosku i status_dokmentów wg nastepujacej definicji
--brak_dokumentu dla wniosków, których nie mamy ¿adnego dokumentu pasa¿era w bazie
--bez_paszportu dla wniosków, gdzie ¿aden z dokumentów nie byl paszportem
--tylko_bilety dla wniosków, którch dokumenty stanowily wylaczenie skany biletu
--standard dla pozostalych

'Select distinct id_wniosku, (count(typ_dokumentu)) as dok_ilosc from dokumenty
group by id_wniosku
order by dok_ilosc desc;'


-- Sprawdzenie bez paszportu
Select w.id, a.typ_dokumentu from wnioski w
left join dokumenty as a on w.id = a.id_wniosku
where w.id = '2057294'
group by w.id, a.typ_dokumentu;

-- Sprawdzenie standard
Select w.id, typ_dokumentu from wnioski w
left join dokumenty as a on w.id = a.id_wniosku
where w.id = '2074845'
group by w.id, typ_dokumentu;

-- Sprawdzenie tylko bilety
Select w.id, typ_dokumentu from wnioski w
left join dokumenty as a on w.id = a.id_wniosku
where w.id = '2052567'
group by w.id, typ_dokumentu;

Select distinct id_wniosku, (count(typ_dokumentu)) as dok_ilosc from dokumenty
group by id_wniosku
order by dok_ilosc desc;

select w.id, count(a.typ_dokumentu) as dok_ilosc,
  (case
    when count(a.typ_dokumentu) = 0 then 'brak dokumentu'
    when sum(case when a.typ_dokumentu = 'skan biletu' then 0
             else 1 end) = 0 then 'tylko bilety'
    when sum(case when a.typ_dokumentu = 'paszport' then 1
             else 0 end) = 0 then 'bez paszportu'
    else 'standard'
  end) as dok_status
from wnioski as w
left join dokumenty as a on w.id = a.id_wniosku
group by w.id
order by dok_ilosc desc;

--2) Za pomoca jednego zapytania (u¿ywajac skladni EXCEPT) wylistuj wnioski,
--dla których czas wyslania wszystkich dokumnetów nie przekroczyl 10 minut,
--(oczywisnie nie bie¿emy pod uwagê takich, gdzie jest tylko jeden dokument)
--i jednoczesnie ich przewoznikiem nie byl TLK

--1. Czas wyslania jako czas przesylania <= 10min'

Select a.id_wniosku from dokumenty a
  GROUP BY a.id_wniosku
  HAVING count(a.id_wniosku) > 1 and
        sum(DATE_PART('day', a.data_otrzymania::timestamp - a.data_wyslania::timestamp) * 24 +
             DATE_PART('hour', a.data_otrzymania::timestamp - a.data_wyslania::timestamp) * 60 +
               DATE_PART('minute', a.data_otrzymania::timestamp - a.data_wyslania::timestamp)) <= 10
EXCEPT
Select b.id_wniosku from podroze b
left join szczegoly_podrozy c on b.id = c.id_podrozy
where c.identyfikator_operatora = 'TLK'
order by id_wniosku;

--2. Czas wyslania tylko po kolumnie data wyslania'

Select a.id_wniosku from dokumenty a
  GROUP BY a.id_wniosku
  HAVING count(a.id_wniosku) > 1 and
          (max(a.data_wyslania) - min(a.data_wyslania)) <=  '10 mins'
EXCEPT
  Select b.id_wniosku from podroze b
  left join szczegoly_podrozy c on b.id = c.id_podrozy
  where c.identyfikator_operatora = 'TLK'
  order by id_wniosku;