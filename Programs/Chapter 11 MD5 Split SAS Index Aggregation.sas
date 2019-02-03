/* "Chapter 11 MD5 Split SAS Index Aggregation.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let N_groups = 256 ;
 
data Dw.Runs_UKS (index=(UKS) drop = _:) ;
  set Dw.Runs ;
  length _concat $ 32 _MD5 $ 16 ;
  _concat = catx (":", Game_SK, Inning, Top_Bot) ;
  _MD5 = md5 (_concat) ;
  UKS = 1 + mod (input (_MD5, pib4.), &N_groups) ;
run ;
 
/* Program 11.25 Chapter 11 MD5 Split SAS Index Aggregation.sas (Part 2) */
 
%let comp_keys = Game_SK Inning Top_Bot ;
 
data Scores_split_index (keep = &comp_keys Score) ;
  if _n_ = 1 then do ;
    dcl hash h() ;
    do _k = 1 to countW ("&comp_keys") ;
      h.defineKey  (scan ("&comp_keys", _k)) ;
      h.defineData (scan ("&comp_keys", _k)) ;
    end ;
    h.defineData("Score") ;
    h.defineDone() ;
    dcl hiter ih("h") ;
  end ;
  do until (last.UKS) ;
    set Dw.Runs_UKS ;
    by UKS ;
    if h.find() ne 0 then Score = 1 ;
    else Score + 1 ;
    h.replace() ;
  end ;
  do while (ih.next() = 0) ;
    output ;
  end ;
  h.clear() ;
run ;
