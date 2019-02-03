/* "Chapter 11 Partial Key Split By Inning Aggregation - Code to Assemble.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Scores_inning_split_test (keep = &comp_keys Score) ;
  if _n_ = 1 then do ;
    dcl hash h (ordered:"A") ;
    do _k = 1 to countW ("&comp_keys") ;
      h.defineKey  (scan ("&comp_keys", _k)) ;
      h.defineData (scan ("&comp_keys", _k)) ;
    end ;
    h.defineData ("Score") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
  end ;
  do LR = 0 by 0 until (LR) ;
    set dw.Runs (where=(Inning in (3,6,9))) end = LR ;
    link SCORE ;
  end ;
  link OUT ;
  do LR = 0 by 0 until (LR) ;
    set dw.Runs (where=(Inning in (1,4,7))) end = LR ;
    link SCORE ;
  end ;
  link OUT ;
  do LR = 0 by 0 until (LR) ;
    set dw.Runs (where=(Inning in (2,5,8))) end = LR ;
    link SCORE ;
  end ;
  link OUT ;
  return ;
  SCORE: if h.find() ne 0 then Score = 1 ;
         else Score + 1 ;
         h.replace() ;
  return ;
  OUT:   do while (ih.next() = 0) ;
           output ;
         end ;
         Num_items = h.num_items ;
         put Num_items= ;
         h.clear() ;
  return ;
run ;
