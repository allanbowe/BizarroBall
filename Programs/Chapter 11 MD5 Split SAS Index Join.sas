/* "Chapter 11 MD5 Split SAS Index Join.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let N_groups = 16 ;
 
data Dw.Runs_UKS (index=(UKS) keep=UKS Game_SK Inning Top_Bot AB_Number
                              Runner_ID)
     Dw.AtBats_UKS (index=(UKS) drop = _: Runner_ID) ;
  set Dw.Runs (in=R) Dw.AtBats ;
  length _concat $ 32 _MD5 $ 16 ;
  _concat = catx (":", Game_SK, Inning, Top_Bot) ;
  _MD5 = md5 (_concat) ;
  UKS = 1 + mod (input (_MD5, pib4.), &N_groups) ;
  if R then output Dw.Runs_UKS ;
  else      output Dw.AtBats_UKS ;
run ;
 
/* Program 11.27 Chapter 11 MD5 Split SAS Index Join.sas (Part 2) */
 
%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let data_vars = Batter_ID Position_code Is_A_Hit Result ;
%let data_list = %sysfunc (tranwrd (&data_vars, %str( ), %str(,))) ;
 
data Join_Runs_AtBats_MD5_SAS_Index (drop = _: Runs) ;
  if _n_ = 1 then do ;
    dcl hash h   (multidata:"Y", ordered:"A") ;
    do _k = 1 to countw ("&comp_keys") ;
      h.defineKey (scan ("&comp_keys", _k)) ;
    end ;
    do _k = 1 to countw ("&data_vars") ;
      h.defineData (scan ("&data_vars", _k)) ;
    end ;
    h.defineDone() ;
  end ;
  do until (last.UKS) ;
    set dw.AtBats_UKS (in=A keep = UKS &comp_keys &data_vars Runs
                       where=(Runs))
        dw.Runs_UKS   (in=R keep = UKS &comp_keys Runner_ID) ;
    by UKS ;
    if A then h.add() ;
    if not R then continue ;
    call missing (&data_list, _count) ;
    do while (h.do_over() = 0) ;
      _count = sum (_count, 1) ;
      output ;
    end ;
   if not _count then output ;
  end ;
  h.clear() ;
run ;
