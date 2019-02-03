/* "Chapter 11 MD5 Key Reduction Aggregation.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let cat_length = 36 ;
 
data Scores_game_inning_MD5 (keep = Game_SK Inning Top_Bot Score) ;
  if _n_ = 1 then do ;
    dcl hash h () ;
    h.defineKey  ("_MD5") ;
    h.defineData ("Game_SK", "Inning", "Top_Bot", "Score") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
  end ;
  do until (LR) ;
    set Dw.Runs end = LR ;
    length _concat $ &cat_length _MD5 $ 16 ;
    _concat = catx (":", Game_SK, Inning, Top_Bot) ;
    _MD5 = MD5 (_concat) ;
    if h.find() ne 0 then Score = 1 ;
    else Score + 1 ;
    h.replace() ;
  end ;
  do while (ih.next() = 0) ;
    output ;
  end ;
run ;
