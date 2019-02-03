/* "Chapter 3 ORDERED Argument Tag as Expression.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  retain Orders "ADN" ;
  dcl hash H ;
  do i = 1 to 3 ;
    H = _NEW_ hash (ORDERED: char (Orders, i)) ;
  end ;
run ;
