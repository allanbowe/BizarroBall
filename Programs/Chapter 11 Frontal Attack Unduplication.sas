/* "Chapter 11 Frontal Attack Unduplication.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data First_scores ;
  if _n_ = 1 then do ;
    dcl hash h () ;
    h.defineKey  ("Game_SK", "Runner_ID") ;
    h.defineData ("_N_") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
 end ;
 do until (LR) ;
   set dw.Runs end = LR ;
   if h.check() = 0 then continue ;
   output ;
   h.add() ;
 end ;
run ;
