/* "Chapter 10 Selective Unduplication via Proc SORT + DATA Step.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sort
  data = dw.Games     (keep=Date Home_SK Away_SK Month DayOfWeek)
  out  = games_sorted (keep=Date Home_SK Away_SK)
  ;
  by Home_SK Date ;
  where Home_SK in (203,246,281) and Month=5 and DayOfWeek=7 ;
run ;
 
data Last_games_sort ;
  set games_sorted ;
  by Home_SK ;
  if last.Home_SK ;
run ;
