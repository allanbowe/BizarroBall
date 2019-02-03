/* "Chapter 11 Key Byte Split By Game_SK Join.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let data_vars = Batter_ID Position_code Is_A_Hit Result ;
%let data_list = %sysfunc (tranwrd (&data_vars, %str( ), %str(,))) ;
*%let UKS_base  = Inning ;
%let UKS_base  = input (Game_SK, pib2.) ;
%let N_groups  = 3 ;
%let UKS_group = mod (&UKS_base,&N_groups) + 1 ;
 
%macro UKS() ;
  %do Group = 1 %to &N_groups ;
    do LR = 0 by 0 until (LR) ;
      set dw.AtBats (keep=&comp_keys &data_vars Runs
                     where=(&UKS_group=&Group and Runs))
          end=LR ;
      h.add() ;
    end ;
    do LR = 0 by 0 until (LR) ;
      set dw.Runs (where=(&UKS_group=&Group)) end=LR ;
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
 
data Join_Game_SK_split (drop = _: Runs) ;
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
