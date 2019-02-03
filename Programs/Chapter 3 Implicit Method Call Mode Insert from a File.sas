/* "Chapter 3 Implicit Method Call Mode Insert from a File.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H () ;
  H.definekey ("Player_ID") ;
  H.definedata ("Player_ID", "Position_code") ;
  H.definedone() ;
  do until (lr) ;
     set bizarro.Player_candidates end = lr ;
     rc = H.ADD() ;
  end ;
  H.output (dataset: "Players") ; *Check content of H;
  stop ;
run ;
