/* "Chapter 6 Splitting Sorted Data via Hash with DELETE Method.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
* if _n_ = 1 then do ;
    /*Create operation code block*/
    dcl hash h (ordered:"A") ;
    h.defineKey ("unique_key") ;
    h.defineData ("League", "Team_SK", "Team_Name") ;
    h.defineDone () ;
* end ;
  do unique_key = 1 by 1 until (last.League) ;
    set bizarro.Teams ;
    by League ;
    h.add() ;
  end ;
  h.output (dataset: catx ("_", "work.League", League)) ;
* h.clear() ;
  /*Delete the instance of object H*/
  h.delete() ;
run ;
