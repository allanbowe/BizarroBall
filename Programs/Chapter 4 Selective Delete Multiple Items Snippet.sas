/* "Chapter 4 Selective Delete Multiple Items Snippet.sas" from the SAS Press book
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
  put "Keynumerate to delete items with D in ('E','F'):" ;
  do ENUM_iter = 1 by 1 until (not MORE_ITEMS) ;
    do RC_enum = H.FIND(KEY:3) by 0 while (RC_enum = 0) ;
      H.HAS_NEXT(RESULT:MORE_ITEMS) ;
      if D in ("E", "F") then H.REMOVEDUP() ;
      RC_enum = H.FIND_NEXT() ;
    end ;
    put +3 ENUM_iter= MORE_ITEMS= ;
  end ;
  put "Keynumerate again to check result:" ;
  do RC_enum = H.FIND(KEY:3) by 0 while (RC_enum = 0) ;
    put +3 RC_enum= D= ;
    RC_enum = H.FIND_NEXT() ;
  end ;
  stop ;
run ;
