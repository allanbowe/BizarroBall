/* "Chapter 3 Implicit Method Call Mode Insert.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H () ;
  H.definekey ("K") ;
  H.definedata ("D") ;
  H.definedone() ;
  K = 1 ;
  D = "A" ;
  rc = H.ADD() ;
run ;
