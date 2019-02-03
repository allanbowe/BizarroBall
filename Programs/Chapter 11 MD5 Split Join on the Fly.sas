/* "Chapter 11 MD5 Split Join on the Fly.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let data_vars = Batter_ID Position_code Is_A_Hit Result ;
%let keys_list = %sysfunc (tranwrd (&comp_keys, %str( ), %str(,))) ;
%let data_list = %sysfunc (tranwrd (&data_vars, %str( ), %str(,))) ;
%let UKS_base  = input (_MD5, pib2.) ;
%let N_groups  = 3 ;
%let UKS_group = mod (&UKS_base,&N_groups) + 1 ;
 
data vRuns / view = vRuns ;
  set dw.Runs ;
  length _concat $ 32 _MD5 $ 16 ;
  _concat = catx (":", &keys_list) ;
  _MD5 = md5 (_concat) ;
run ;
 
data vAtBats / view = vatBats ;
  set dw.AtBats ;
  length _concat $ 32 _MD5 $ 16 ;
  _concat = catx (":", &keys_list) ;
  _MD5 = md5 (_concat) ;
run ;
 
%macro UKS() ;
  %do Group = 1 %to &N_groups ;
    do LR = 0 by 0 until (LR) ;
      set vAtBats (keep=&comp_keys &data_vars Runs _MD5
                   where=(&UKS_group=&Group and Runs))
          end=LR ;
      h.add() ;
    end ;
    do LR = 0 by 0 until (LR) ;
      set vRuns (where=(&UKS_group=&Group)) end=LR ;
      call missing (&data_list, _count) ;
      do while (h.do_over() = 0) ;
        _count = sum (_count, 1) ;
        output ;
      end ;
      if not _count then output ;
    end ;
    h.clear() ;
  %end ;
%mEnd ;
 
data Join_MD5_OnTheFly_Split (drop = _: Runs) ;
  dcl hash h (multidata:"Y", ordered:"A") ;
  do _k = 1 to countw ("&comp_keys") ;
    h.defineKey (scan ("&comp_keys", _k)) ;
  end ;
  do _k = 1 to countw ("&data_vars") ;
    h.defineData (scan ("&data_vars", _k)) ;
  end ;
  h.defineDone() ;
  %UKS()
  stop ;
run ;
