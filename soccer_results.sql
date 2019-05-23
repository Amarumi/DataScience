
  'a. Jaka była największa różnica strzelonych bramek w finałach mistrzostw świata
       'lub kwalifikacjach do mistrzostw świata (FIFA World Cup, FIFA World Cup qualification)
  'b. Ile meczy rozegrali Polacy w Hiszpanii
  'c. Ile łącznie padło bramek na UEFA Euro
  'd. Jaka jest średnia liczba bramek strzelona w meczach towarzyskich rozegranych
       terytorium Polski
  'e. Data pierwszego meczu reprezentacji Polski w mieście Rosario (Argentina)

Select * from wnioski
SELECT MAX (ABS(home_score - away_score)) from results
WHERE tournament = 'FIFA World Cup' OR tournament = 'FIFA World Cup qualification'
'=31'

SELECT COUNT (*) from results
WHERE country = 'Spain' AND (away_team = 'Poland' OR home_team = 'Poland');
'=20'

'Sprawdzenie danych w tabeli Select * from results WHERE home <=> country'

SELECT SUM (home_score + away_score)  from results
WHERE tournament = 'UEFA Euro'
'=687'

SELECT CAST((SUM (home_score + away_score)) AS DECIMAL (10,2)) / COUNT (tournament) from results
WHERE tournament = 'Friendly'
'=2.9036115236251897'

SELECT MIN (date) from results
WHERE city = 'Rosario' AND away_team = 'Poland' AND country = 'Argentina' OR city = 'Rosario' AND home_team = 'Poland' AND country = 'Argentina'
'WHERE city = ''Rosario'' AND (away_team = ''Poland'' OR home_team = ''Poland'' ) AND country = ''Argentina''' ||
 '=1978-06-06'
