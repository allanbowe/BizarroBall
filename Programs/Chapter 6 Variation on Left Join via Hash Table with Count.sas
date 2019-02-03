/* "Chapter 6 Variation on Left Join via Hash Table with Count.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

  do while (triple.do_over() = 0) ;
    Count = sum (Count, 1) ;
  end ;
  call missing (Distance, Direction) ;
  do while (triple.do_over() = 0) ;
    output ;
  end ;
  if not Count then output ;
