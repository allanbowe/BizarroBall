/* "Chapter 6 Intrinsic Hash Table Grouping.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash h (multidata:"Y") ;
  h.defineKey ("Batter_ID") ;
  h.defineData ("Batter_id", "Result", "Sequence") ;
  h.defineDone () ;
  do until (lr) ;
    set Sample end = lr ;
    h.add() ;
  end ;
  h.output (dataset: "Grouped") ;
  stop ;
run ;
