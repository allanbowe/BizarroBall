/* "Chapter 11 MD5 Key Reduction Join.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let data_vars = Batter_ID Position_code Is_A_Hit Result ;
%let data_list = %sysfunc (tranwrd (&data_vars, %str( ), %str(,))) ;
%let keys_list = %sysfunc (tranwrd (&comp_keys, %str( ), %str(,))) ;
 
%let cat_length = 52 ;
 
data Join_Runs_AtBats_MD5 (drop = _: Runs) ;
  if _n_ = 1 then do ;
    dcl hash h (multidata:"Y", ordered:"A") ;
    h.defineKey ("_MD5") ;
    do _k = 1 to countw ("&data_vars") ;
      h.defineData (scan ("&data_vars", _k)) ;
    end ;
    h.defineDone() ;
    do until (LR) ;
      set dw.AtBats (keep=&comp_keys &data_vars Runs
                     where=(Runs)) end = LR ;
      link MD5 ;
      h.add() ;
    end ;
  end ;
  set dw.Runs ;
  link MD5 ;
  call missing (&data_list, _count) ;
  do while (h.do_over() = 0) ;
    _count = sum (_count, 1) ;
    output ;
  end ;
  if not _count then output ;
  return ;
  MD5: length _concat $ &cat_length _MD5 $ 16 ;
       _concat = catx ("", &keys_list) ;
       _MD5 = MD5 (_concat) ;
  return ;
run ;
