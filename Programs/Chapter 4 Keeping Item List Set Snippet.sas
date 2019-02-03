/* "Chapter 4 Keeping Item List Set Snippet.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H (multidata:"Y", ordered:"N") ;
  H.definekey ("K") ;
  H.definedata ("D") ;
  H.definedone () ;
  do K = 1, 2, 2, 3, 3, 3 ;
    q + 1 ;
    D = char ("ABCDEF", q) ;
    H.ADD() ;
  end ;
  h.output(dataset: "AsLoaded") ;
  call missing (K, D, RC) ;
  put "Forward:" ;
  RC = H.FIND(KEY:3) ;
  do while (1) ;
    put +3 RC= D= ;
    RC = H.HAS_NEXT(RESULT:NEXT) ;
    if not NEXT then LEAVE ;
    RC = H.FIND_NEXT() ;
  end ;
  put "Backward:" ;
  do while (1) ;
  RC = H.HAS_PREV(RESULT:PREV) ;
    if not PREV then LEAVE ;
    RC = H.FIND_PREV() ;
    put +3 RC= D= ;
  end ;
  put "Forward:" ;
  do while (1) ;
    RC = H.HAS_NEXT(RESULT:NEXT) ;
    if not NEXT then LEAVE ;
    RC = H.FIND_NEXT() ;
    put +3 RC= D= ;
  end ;
  stop ;
run ;
