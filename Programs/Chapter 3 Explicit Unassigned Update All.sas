/* "Chapter 3 Explicit Unassigned Update All.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H (multidata:"Y") ;
  H.definekey ("K") ;
  H.definedata ("D") ;
  H.definedone() ;
  do K = 1, 2, 2 ;
    q + 1 ;
    D = char ("ABC", q) ;
    rc = H.add() ;
  end ;
  H.REPLACE(KEY:1, DATA:"X") ;
  H.REPLACE(KEY:2, DATA:"Y") ;
  H.REPLACE(KEY:3, DATA:"Z") ;
run ;
