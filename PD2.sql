--1. Policzyć liczbę wniosków oraz średnią kwotę rekompensaty w agregacji kod krju i powód operatora.
    -- Posortować malejąco po średniej kwocie i wyświetlić tylko takie pozycje , które mają więcej niż 10 wniosków.

SELECT kod_kraju, powod_operatora, AVG(kwota_rekompensaty), count (1) as wynik FROM wnioski
GROUP by kod_kraju, powod_operatora
HAVING count(1) >10
ORDER by AVG(kwota_rekompensaty) DESC


--2. Policzyć ile w każdym roku było wniosków, których źródłem polecenia był facebook lub twitter oraz takich,
    -- które były wypłacone z powodu pogody. Podpowiedź można zastosować składnię: sum( case when … end).
    'przez dodana podpowiedz  rozumiem 'oraz takich..' jako wnioski o innym zrodle polecenia, ale wyplacone z powodu pogody, ' ||
     'jesli zle rozumiem, to AND zamiast OR, ale wtedy count (case.. ) daje inny wynik'


SELECT to_char (data_utworzenia, 'YYYY') as wynik,
count (CASE when zrodlo_polecenia = 'fb / twitter' then 'fb / twitter'END) as zrodlo_FBTW,
count (CASE when powod_operatora = 'pogoda' AND stan_wniosku = 'wyplacony' then 'wyplacone_pogoda' END) as wyplacone_pogoda
FROM wnioski
GROUP by wynik

-- 3. Wyliczyć liczbę wniosków z kwotą rekompensaty pomiędzy 500 a 1000 w agregacji na język – polski, angielski,
    -- niemiecki i inny oraz kategorię opóźnienia. Posortować rosnąco po kategorii opóźnienia
    --  następnie po liczbie wniosków.

Select count(1) as liczba_wnioskow,
       case when typ_wniosku = 'opozniony'then powod_operatora
           end as kategoria_opoznienia,
CASE
    when jezyk = 'de' then 'niemiecki'
    when jezyk = 'en' then 'angielski'
    when jezyk = 'pl' then 'polski'
    else 'inny'
END as nazwa_jezyk
from wnioski
where kwota_rekompensaty >=500
AND kwota_rekompensaty <=1000
group by nazwa_jezyk, kategoria_opoznienia
order by kategoria_opoznienia, liczba_wnioskow asc ;
