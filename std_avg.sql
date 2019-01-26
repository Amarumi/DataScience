--1) zrobić zestawienie w którym wylistuemy wszytkie wnioski wraz z informacją o kraju, opłatą za usługę
 --wyrażoną kwotowo (nie procentowo) i informacją jaki % średniej opłaty w danym kraju ta opłata stanowi

    Select id, kod_kraju,
       sum(kwota_rekompensaty*(oplata_za_usluge_procent + oplata_za_usluge_prawnicza_procent))/100 as oplata,
       round(
          (sum(kwota_rekompensaty*(oplata_za_usluge_procent + oplata_za_usluge_prawnicza_procent)))
            /
          (avg(kwota_rekompensaty*(oplata_za_usluge_procent + oplata_za_usluge_prawnicza_procent)/100)
               over (partition by kod_kraju)),2) as proc_srednia_kraj
    from wnioski
    group by id
    order by kod_kraju;

--2) dla odrzuconych wniosków dla których mamy dokumenty w bazie, zrobić zestawienie id dokumentu,
--id_wniosku data otrzymania oraz różnica czasu od otrzymania pierwszego dokumentu w ramach danego wniosku
--(pierwszy otrzymany dokument oczywście będzie miał różnicę 0)

  Select a.id as id_dokument, w.id as id_wniosek, a.data_otrzymania,
    a.data_otrzymania - min(a.data_otrzymania) over (partition by a.id_wniosku) as czasu_od_otrzymania_pierwszego_dok
  from wnioski w
  join dokumenty a on w.id = a.id_wniosku
  where w.stan_wniosku like '%odrzucony%'
  group by w.id, a.id;


--3) Dla wniosków z polski zrobić zestawienie wniosków, stanu_wniosku, kwoty rekompensaty oraz informację
--czy ta kwota mieście się w 95% przedziale ufności kwot rekompensaty dla danego stanu wniosku
--(zakładamy że 95% przedział ufności to przedział (avg - 2SD, avg + 2SD)

  Select w.id, w.kod_kraju, w.stan_wniosku, w.kwota_rekompensaty,
      avg(w.kwota_rekompensaty) over (partition by w.stan_wniosku) as srednia_rekompensata,
      ((avg(w.kwota_rekompensaty) over (partition by w.stan_wniosku))
        - 2 * (stddev(w.kwota_rekompensaty) over (partition by w.stan_wniosku))) as dolny_przed_uf,
      ((avg(w.kwota_rekompensaty) over (partition by w.stan_wniosku))
        + 2 * (stddev(w.kwota_rekompensaty) over (partition by w.stan_wniosku))) as gorny_przed_uf,
      w.kwota_rekompensaty between
        ((avg(w.kwota_rekompensaty) over (partition by w.stan_wniosku))
        - 2 * (stddev(w.kwota_rekompensaty) over (partition by w.stan_wniosku))) and
        ((avg(w.kwota_rekompensaty) over (partition by w.stan_wniosku))
        + 2 * (stddev(w.kwota_rekompensaty) over (partition by w.stan_wniosku))) as czy_sie_miesci
        from wnioski w
  where UPPER(w.kod_kraju) = 'PL' and w.kwota_rekompensaty is not null
  group by w.id;

