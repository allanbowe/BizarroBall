/* "Chapter 11 Pregrouped Aggregation.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Scores_grouped (keep = Game_SK Top_Bot Score) ;
  if _n_ = 1 then do ;
    dcl hash h (ordered:"A") ;
    h.defineKey  ("Top_Bot") ;
    h.defineData ("Top_Bot", "Score") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
 end ;
 do until (last.Game_SK) ;
   set Dw.Runs (keep = Game_SK Top_Bot) ;
   by Game_SK ;
   if h.find() ne 0 then Score = 1 ;
   else Score + 1 ;
   h.replace() ;
 end ;
 do while (ih.next() = 0) ;
   output ;
 end ;
 h.clear() ;
run ;
