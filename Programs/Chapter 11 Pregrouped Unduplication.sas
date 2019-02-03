/* "Chapter 11 Pregrouped Unduplication.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data First_scores_grouped ;
  if _n_ = 1 then do ;
    dcl hash h () ;
    h.defineKey  ("Runner_ID") ;
    h.defineData ("_iorc_") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
  end ;
  do until (last.Game_SK) ;
    set dw.Runs (keep = Game_SK Inning Top_Bot Runner_ID) ;
    by Game_SK ;
    if h.check() = 0 then continue ;
    output ;
    h.add() ;
  end ;
  h.clear() ;
run ;
