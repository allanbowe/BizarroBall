/* "Chapter 4 Enumerate from First Item Snippet.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H (multidata:"Y", ordered:"N") ;
  H.definekey ("K") ;
  H.definedata ("D", "K") ;
  H.definedone () ;
  do K = 1, 2, 2, 3, 3, 3 ;
    q + 1 ;
    D = char ("ABCDEF", q) ;
    H.add() ;
  end ;
  DECLARE HITER IH ;
  IH = _NEW_ HITER ("H") ;
  call missing (K, D) ;
  RC = IH.FIRST() ;
  put RC= K= D= ;
  RC = IH.NEXT() ;
  put RC= K= D= ;
  stop ;
run ;
