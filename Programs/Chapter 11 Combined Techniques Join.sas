/* "Chapter 11 Combined Techniques Join.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let sort_keys = Game_SK ;
%let data_vars = Batter_ID Position_code Is_A_Hit Result ;
%let tail_keys = %sysfunc (tranwrd (&comp_keys, &sort_keys, %str())) ;
%let last_key  = %sysfunc (scan (&sort_keys, -1)) ;
%let tail_list = %sysfunc (tranwrd (&tail_keys, %str( ), %str(,))) ;
%let data_list = %sysfunc (tranwrd (&data_vars, %str( ), %str(,))) ;
 
data Join_Runs_AtBats_combine (drop = _: Runs) ;
  if _n_ = 1 then do ;
    dcl hash h (multidata:"Y", ordered:"A") ;
    h.defineKey  ("_MD5") ;
    h.defineData ("RID") ;
    h.defineDone() ;
  end ;
  do until (last.&last_key) ;
    set dw.AtBats (in=A keep=&comp_keys Runs)
        dw.Runs   (in=R keep=&comp_keys Runner_ID) ;
    by &sort_keys ;
    if A = 1 then do ;
      _RID + 1 ;
      if not Runs then continue ;
    end ;
    length _concat $ 37 _MD5 $ 16 ;
    _concat = catx (":", &tail_list) ;
    _MD5 = md5 (_concat) ;
    if A = 1 then h.add(key:_MD5, data:_RID) ;
    if R = 0 then continue ;
    do while (h.do_over() = 0) ;
      _count = sum (_count, 1) ;
      set dw.AtBats (keep=&data_vars) point=RID ;
      output ;
    end ;
    if not _count then output ;
    call missing (&data_list, _count) ;
  end ;
  h.clear() ;
run ;
