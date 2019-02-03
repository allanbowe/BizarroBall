/* "Chapter 2 Define Multiple Hash Variables.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H() ;
  H.defineKey ("Player_ID","Team_SK") ;
  H.defineData("First_name","Last_name","Position_code") ;
  H.defineDone() ;
  stop ;
  set bizarro.Player_candidates ;
run ;
