/* "Chapter 6 Splitting Data - Hard Coded.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data League_1 League_2 ;
  set Bizarro.Teams ;
  select (League) ;
    when (1) output League_1 ;
    when (2) output League_2 ;
    otherwise ;
  end ;
run ;
