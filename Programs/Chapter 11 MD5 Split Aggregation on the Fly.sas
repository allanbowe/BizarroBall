/* "Chapter 11 MD5 Split Aggregation on the Fly.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot ;
%let keys_list = %sysfunc (tranwrd (&comp_keys, %str( ), %str(,))) ;
%let UKS_base  = input (_MD5, pib2.) ;
%let N_groups  = 4 ;
%let UKS_group = mod (&UKS_base,&N_groups) + 1 ;
 
data vRuns / view = vRuns ;
  set dw.Runs ;
  length _concat $ 32 _MD5 $ 16 ;
  _concat = catx (":", &keys_list) ;
  _MD5 = md5 (_concat) ;
run ;
 
%macro UKS() ;
  %do Group = 1 %to &N_groups ;
    do LR = 0 by 0 until (LR) ;
      set vRuns (where=(&UKS_group=&Group)) end = LR ;
      link SCORE ;
    end ;
    link OUT ;
  %end ;
%mEnd ;
 
data Scores_MD5_OnTheFly_Split (keep = &comp_keys Score) ;
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
  %UKS()
  return ;
  SCORE: if h.find() ne 0 then Score = 1 ;
         else Score + 1 ;
         h.replace() ;
  return ;
  OUT:   do while (ih.next() = 0) ;
           output ;
         end ;
       * Num_items = h.num_items ;
       * put Num_items= ;
         h.clear() ;
  return ;
run ;
