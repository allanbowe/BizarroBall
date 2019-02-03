/* "Chapter 6 Variation on Left Join via Hash Table with Multiple Aggregates.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

  do while (triple.do_over() = 0) ;
    Count = sum (Count, 1) ;
    TotalDistance = sum (TotalDistance, Distance) ;
  end ;
  AvgDistance = divide (TotalDistance, Count) ;
