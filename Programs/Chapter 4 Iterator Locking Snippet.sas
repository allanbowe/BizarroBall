/* "Chapter 4 Iterator Locking Snippet.sas" from the SAS Press book
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
 
  _K = 2 ; * <--Key-value to delete ;
  RC = IH.FIRST() ;
* RC = IH.NEXT() ;
* RC = IH.NEXT() ;
  put "Item:" +3 K= D= RC= ;
  RC = H.REMOVE(KEY:_K) ;
  put "Remove:" +1 RC= ;
  RC = H.CHECK(KEY:_K) ;
  put "Check:" +2 RC= ;
 
  stop ;
run ;
