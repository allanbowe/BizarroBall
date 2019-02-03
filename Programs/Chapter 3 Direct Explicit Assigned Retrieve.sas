/* "Chapter 3 Direct Explicit Assigned Retrieve.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H  (multidata:"Y") ;
  H.definekey ("K") ;
  H.definedata("D") ;
  H.definedone() ;
  do K = 1, 2, 2 ;
    q + 1 ;
    D = char ("ABC", q) ;
    H.add() ;
  end ;
  D = "X" ;            *pre-call value of PDV host variable D;
  RC = H.FIND(KEY:1) ;
  put D= RC= ;
run ;
