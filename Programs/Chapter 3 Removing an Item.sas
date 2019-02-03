/* "Chapter 3 Removing an Item.sas" from the SAS Press book
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
    rc = H.add() ;
  end ;
  rc = H.REMOVE() ; *implicit/assigned call
run ;
