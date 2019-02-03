/* "Chapter 11 Frontal Attack Join.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let data_vars = Batter_ID Is_A_Hit Result ;
%let data_list = %sysfunc (tranwrd (&data_vars, %str( ), %str(,))) ;
 
data Join_Runs_AtBats (drop = _: Runs) ;
  if _n_ = 1 then do ;
    dcl hash h (multidata:"Y", ordered:"A") ;
    do _k = 1 to countw ("&comp_keys") ;
      h.defineKey (scan ("&comp_keys", _k)) ;
    end ;
    do _k = 1 to countw ("&data_vars") ;
      h.defineData (scan ("&data_vars", _k)) ;
    end ;
    h.defineDone() ;
    do until (LR) ;
      set dw.AtBats (keep=&comp_keys &data_vars Runs
                     where=(Runs)) end = LR ;
      h.add() ;
    end ;
  end ;
  set dw.Runs ;
  call missing (&data_list, _count) ;
  do while (h.do_over() = 0) ;
    _count = sum (_count, 1) ;
    output ;
  end ;
  if not _count then output ;
run ;
