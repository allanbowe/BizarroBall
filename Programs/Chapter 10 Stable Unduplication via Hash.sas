/* "Chapter 10 Stable Unduplication via Hash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data nodup_hash dupes_hash ;
  if _n_ = 1 then do ;
    dcl hash h () ;
    h.defineKey ("Batter_ID") ;
    h.defineDone () ;
  end ;
  set dw.AtBats (keep = Game_SK Batter_ID Result Top_Bot Inning) ;
  where Batter_ID in (32390,51986,60088)
  and   Result  = "Triple"
  and   Top_Bot = "B"
  and   Inning  = 1
  ;
  if h.check() ne 0 then do ;
    output nodup_hash ;
    h.add() ;
  end ;
  else output dupes_hash ;
  keep Game_SK Batter_ID ;
run ;
