/* "Chapter 11 Frontal Attack Aggregation Inning.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Scores_game_inning (keep = Game_SK Inning  Top_Bot Score) ;
  if _n_ = 1 then do ;
    dcl hash h (ordered:"A") ;
    h.defineKey  ("Game_SK", "Inning", "Top_Bot") ;
    h.defineData ("Game_SK", "Inning", "Top_Bot", "Score") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
  end ;
  do until (LR) ;
    set Dw.Runs (keep = Game_SK Inning Top_Bot) end = LR ;
    if h.find() ne 0 then Score = 1 ;
    else Score + 1 ;
    h.replace() ;
  end ;
  do while (ih.next() = 0) ;
    output ;
  end ;
run ;
