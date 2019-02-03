/* "Chapter 4 Enumerating from Key-Item Snippet.sas" from the SAS Press book
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
  RC = IH.SETCUR(KEY:3) ;
  do count = 1 to 2 while (RC = 0) ;
    RC = IH.PREV() ;
    if RC = 0 then put K= D= RC= ;
  end ;
  stop ;
run ;
