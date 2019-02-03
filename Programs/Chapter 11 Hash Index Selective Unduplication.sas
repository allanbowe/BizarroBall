/* "Chapter 11 Hash Index Selective Unduplication.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Last_away_hash_RID (drop = _:) ;
  dcl hash h   (ordered:"A") ;
  h.defineKey  ("Home_SK") ;
  h.defineData ("Date", "RID") ;
  h.defineDone () ;
  do _RID = 1 by 1 until (lr) ;
    set dw.Games (keep = Date Home_SK) end = lr ;
    _Date =  Date ;
    RID  = _RID ;
    if h.find() ne 0 then h.add() ;
    else if _Date > Date then
    h.replace (key:Home_SK, data:_Date, data:_RID) ;
  end ;
  dcl hiter hi ("h") ;
  do while (hi.next() = 0) ;
    set dw.Games (keep = Home_SK Away_SK Game_SK) point = RID ;
    output ;
  end ;
  stop ;
run ;
