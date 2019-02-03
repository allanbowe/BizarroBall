/* "Chapter 10 Testing Data for Grouping via Hash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  if _n_ = 1 then do ;
    dcl hash h () ;
    h.definekey ("Game_SK", "Inning", "Top_Bot") ;
    h.definedone () ;
  end ;
  if LR then call symput ("Grouped", "1") ;
  do until (last.Top_Bot) ;
    set dw.Runs end = LR ;
    by Game_SK Inning Top_Bot notsorted ;
  end ;
  if h.check() ne 0 then h.add() ;
  else do ;
    call symput ("Grouped", "0") ;
    stop ;
  end ;
run ;
%put &=Grouped ;
