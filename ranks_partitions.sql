-----------------------------------------------------------------------------
--Dla kazdego wniosku dla, ktorego nastapila rekompensata ale nie by�o informacji o �r�dle polecnia
--przyporz�dkuj dok�adnie 1 wniosek podobny, kt�ry:
	-- jest z tego samego rodzaju konta (tabela szczegoly_rekompensat)  oraz jest wyp�acony z tego samego powodu
	-- ma informacj� o �r�dle polecenia i zosta� utworzony wcze�niej ni� por�wnywany wniosek.
	-- ma kwot� rekompensaty identyczn�, b�d� mo�liwie jak najbardziej podobn�,
	--	w przypadku r�wnych kwot kilku wniosk�w podobnych, wybra� ten, kt�ry zosta� z�o�ony w najmniejszym odstepnie czasowym od por�wnywanego wniosku

--Wylistowa� id wniosku i jego kwot� rekompensaty, id wniosku podobnego oraz �r�d�o wniosku podeobnego
--Ponadto z powy�szego zestawienia zrobi� podsumowanie z liczb� i �redni� kwot� wniosk�w ze wzgl�du na �r�d�o wniosku podobnego.

--Uwaga !
--Dla cz�ci wniosk�w nie znajdziemy �adngo wniosku podobnego spe�niaj�cego powy�sze wymagania.

with lista_wnioski as (
   select DISTINCT lw.id, lw.kwota_rekompensaty, d.konto, lw.zrodlo_polecenia, lw.powod_operatora, lw.data_utworzenia
   from wnioski lw
   join rekompensaty s ON lw.id = s.id_wniosku
   join szczegoly_rekompensat d ON s.id = d.id_rekompensaty
   where lw.kwota_rekompensaty > 0 and lw.stan_wniosku like 'wypl%' and lw.zrodlo_polecenia is null
   order by 1
),
podobne_wnioski as (
   select pw.id, pw.kwota_rekompensaty, dd.konto, pw.zrodlo_polecenia, pw.powod_operatora, pw.data_utworzenia
   from wnioski pw
   join rekompensaty ss ON pw.id = ss.id_wniosku
   join szczegoly_rekompensat dd ON ss.id = dd.id_rekompensaty
   where pw.kwota_rekompensaty > 0 and pw.stan_wniosku like 'wypl%' and pw.zrodlo_polecenia is not null
   order by 1
),
moja_lista as (
    select t1.id, t1.kwota_rekompensaty,
           t2.id as id_podobne, t2.zrodlo_polecenia,
           (min(t1.data_utworzenia-t2.data_utworzenia) =
              min(t1.data_utworzenia-t2.data_utworzenia) over (partition by t1.id)) czas_min,
            (min(ABS(t1.kwota_rekompensaty - t2.kwota_rekompensaty)) =
              min(ABS(t1.kwota_rekompensaty - t2.kwota_rekompensaty)) over (order by t2.id)) min_roznica_komp
    from lista_wnioski t1
    join podobne_wnioski t2 on (
          t1.konto = t2.konto and
          t1.powod_operatora = t2.powod_operatora and
          t2.data_utworzenia < t1.data_utworzenia
          )
    group by t1.id, t1.kwota_rekompensaty, t2.id, t2.zrodlo_polecenia, t1.data_utworzenia, t2.data_utworzenia, t2.kwota_rekompensaty
)
select *
from moja_lista
where czas_min is TRUE and min_roznica_komp is TRUE
order by 1;


--ROZWIAZANIE KRZYSZTOFA


with wn_rek as
(select distinct
w.id,
w.powod_operatora,
w.kwota_rekompensaty,
w.zrodlo_polecenia,
s.konto,
w.data_utworzenia
from
wnioski w
join rekompensaty r on w.id = r.id_wniosku
join szczegoly_rekompensat s on r.id = s.id_rekompensaty),

podobne as
(select * from (select w1.id,
                       w1.konto,
                       w1.kwota_rekompensaty,
                       w2.id id_wniosek_podobny,
                       w2.zrodlo_polecenia zrodo_podobnego,
                       rank()over (partition by w1.id order by abs(w1.kwota_rekompensaty - w2.kwota_rekompensaty), (
                         w1.data_utworzenia - w2.data_utworzenia), w2.id) rk
                from wn_rek w1
                        join wn_rek w2 on w1.konto = w2.konto
                                                and w1.powod_operatora = w2.powod_operatora
                                                and w2.zrodlo_polecenia is not null
                                                and w1.zrodlo_polecenia is null
                  and w1.data_utworzenia > w2.data_utworzenia) k
where rk =1)

select zrodo_podobnego, count(*) lp,
    avg(kwota_rekompensaty)
from
podobne
group by zrodo_podobnego;

