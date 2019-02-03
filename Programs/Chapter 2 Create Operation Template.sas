/* "Chapter 2 Create Operation Template.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  declare hash H ;
  H = _new_ hash() ;
  H.defineKey ("K") ;
  H.defineData ("D") ;
  H.defineDone () ;
  stop ;
  K = . ;
  D = "" ;
run ;
