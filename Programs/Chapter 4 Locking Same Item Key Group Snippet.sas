/* "Chapter 4 Locking Same Item Key Group Snippet.sas" from the SAS Press book
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
  IH = _NEW_ hiter ("H") ;
  call missing (K, D) ;
 
  RC = IH.FIRST() ;
  RC = H.FIND(KEY:2) ;
  RC = H.FIND_NEXT(KEY:2) ;
  RC = H.REMOVEDUP(KEY:2) ;
  put RC= ;
 
  stop ;
run ;
