/* "Chapter 6 Splitting Unsorted Data via Hash of Hashes.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  if _n_ = 1 then do ;
    dcl hash h ;
    dcl hash hoh() ;
    hoh.defineKey ("League") ;
    hoh.defineData ("h", "League") ;
    hoh.defineDone () ;
  end ;
  set bizarro.Teams end = lr ;
  if hoh.find() ne 0 then do ;
    h = _new_ hash (multidata:"Y") ;
    h.defineKey ("_iorc_") ;
    h.defineData ("League", "Team_SK", "Team_Name") ;
    h.defineDone () ;
    hoh.add() ;
  end ;
  h.add() ;
  if lr ;
  dcl hiter ihoh ("hoh") ;
  do while (ihoh.next() = 0) ;
     h.output (dataset: catx ("_", "work.League", League)) ;
  end ;
run ;
