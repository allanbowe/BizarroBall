/* "Chapter 6 Simple Stable Unduplication via Hash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data nodup_hash dupes_hash ;
  if _n_ = 1 then do ;
    dcl hash h () ;
    h.defineKey ("Batter_ID") ;
    h.defineDone () ;
  end ;
  set bizarro.AtBats ;
  where Team_SK = 193
  and   Result = "Triple"
  and   Top_Bot = "B" ;
  if h.check() ne 0 then do ;
    output nodup_hash ;
    h.add() ;
  end ;
  else output dupes_hash ;
  keep Date Batter_ID Inning ;
run ;
