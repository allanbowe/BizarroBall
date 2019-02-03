/* "Chapter 10 Selective Unduplication via Hash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash h (ordered:"A") ;
  h.defineKey  ("Home_SK") ;
  h.defineData ("Home_SK", "Date", "Away_SK") ;
  h.defineDone () ;
  do until (lr) ;
    set dw.Games (keep=Date Home_SK Away_SK Month DayOfWeek) end=lr ;
    where Home_SK in (203,246,281) and Month=5 and DayOfWeek=7 ;
    _Date    = Date ;
    _Away_SK = Away_SK ;
    if h.find() ne 0 then h.add() ;
    else if _Date > Date then
    h.replace(key:Home_SK, data:Home_SK, data:_Date, data:_Away_SK) ;
  end ;
  h.output (dataset: "Last_games_hash") ;
  stop ;
run ;
