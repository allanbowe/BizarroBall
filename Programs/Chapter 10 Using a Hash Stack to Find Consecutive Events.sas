/* "Chapter 10 Using a Hash Stack to Find Consecutive Events.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data StackOut (keep = Game_SK Result Count) ;
  if _n_ = 1 then do ;
    dcl hash stack (ordered:"A") ;
    stack.defineKey  ("_N_") ;
    stack.defineData ("_N_", "Game_SK", "Result", "Count") ;
    stack.defineDone () ;
    dcl hiter istack ("stack") ;
  end ;
  do until (last.Result) ;
    set dw.AtBats (keep = Game_SK Result) end = LR ;
    by Game_SK Result notsorted ;
    Count = sum (Count, 1) ;
  end ;
  if Result = "Home Run" and Count => 4 then stack.add() ;
  if LR ;
  do pop = 1 to 6 while (istack.last() = 0) ;
    output ;
    rc = istack.next() ;
    stack.remove() ;
  end ;
run ;
