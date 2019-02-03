/* "Chapter 4 Harvesting Same Key Items from Key Item Snippet.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H (multidata:"Y", ordered:"A") ;
  H.definekey ("K") ;
  H.definedata ("D", "K") ;
  H.definedone () ;
  do K = 1, 2, 2, 3, 3, 3 ;
    q + 1 ;
    D = char ("ABCDEF", q) ;
    H.add() ;
  end ;
  DECLARE HITER IH ;
  IH = _NEW_ hiter ("H") ;
  call missing (K, D) ;
  _K = 2 ;
  do RC = IH.SETCUR(KEY:_K) by 0 while (RC = 0 and K = _K) ;
    put K= D= RC= ;
    RC = IH.NEXT() ;
  end ;
  put RC= ;
  stop ;
run ;
