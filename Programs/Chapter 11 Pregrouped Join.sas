/* "Chapter 11 Pregrouped Join.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let comp_keys = Game_SK Inning Top_Bot AB_Number ;
%let data_vars = Batter_ID Is_A_Hit Result ;
%let data_list = Batter_ID,Is_A_Hit,Result ;
%let sort_keys = Game_SK Inning ;
%let tail_keys = Top_Bot Ab_Number ;
%let last_key  = Inning ;
 
data Join_Runs_AtBats_grouped (drop = _: Runs) ;
  if _n_ = 1 then do ;
    dcl hash h (multidata:"Y", ordered:"A") ;
    do _k = 1 to countw ("&tail_keys") ;
      h.defineKey (scan ("&tail_keys", _k)) ;
    end ;
    do _k = 1 to countw ("&data_vars") ;
      h.defineData (scan ("&data_vars", _k)) ;
    end ;
    h.defineDone() ;
  end ;
  do until (last.&last_key) ;
    set dw.atbats (in=A keep=&comp_keys &data_vars
                             Runs where=(Runs))
        dw.runs   (in=R keep=&comp_keys Runner_ID)
    ;
    by &sort_keys ;
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
