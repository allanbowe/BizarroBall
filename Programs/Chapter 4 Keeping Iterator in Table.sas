/* "Chapter 4 Keeping Iterator in Table.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Forward  (keep=ItemNo K D)
     Backward (keep=ItemNo K D)
  ;
  dcl hash H (multidata:"Y", ordered:"N") ;
  H.definekey ("K") ;
  H.definedata ("D", "K") ;
  H.definedone () ;
  do K = 1, 2, 2, 3, 3, 3 ;
    q + 1 ;
    D = char ("ABCDEF", q) ;
    H.add() ;
  end ;
  dcl hiter IH ("H") ;
  do ItemNo = 1 to H.Num_Items ;
    RC = IH.NEXT() ;
    output Forward ;
  end ;
  /* end of forward loop */
  do ItemNo = H.Num_Items - 1 by -1 to 1 ;
    RC = IH.PREV() ;
    output Backward ;
  end ;
run ;
