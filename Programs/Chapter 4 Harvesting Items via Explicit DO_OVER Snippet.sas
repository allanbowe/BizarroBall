/* "Chapter 4 Harvesting Items via Explicit DO_OVER Snippet.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data harvest (keep = K D) ;
  dcl hash H (multidata:"Y", ordered:"N") ;
  H.definekey ("K") ;
  H.definedata ("D") ;
  H.definedone () ;
  do K = 1, 2, 2, 3, 3, 3 ;
    q + 1 ;
    D = char ("ABCDEF", q) ;
    H.add() ;
  end ;
  array keySet [5] _temporary_ (0 1 5 7 3) ;
  K = . ;
  do i = 1 to dim (keySet) ;
    do while (H.DO_OVER(KEY:keySet[i]) = 0) ;
      output ;
    end ;
  end ;
  stop ;
run ;
