/* "Chapter 11 Full Unduplication.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Games_dup ;
  set Dw.Games ;
  do _n_ = 1 to floor (ranuni(1) * 4) ;
    output ;
  end ;
run ;
 
%let cat_length = 53 ;
 
data Games_nodup (drop = _:) ;
  if _n_ = 1 then do ;
    dcl hash h() ;
    h.defineKey  ("_MD5") ;
    h.defineData ("_N_") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
  end ;
  do until (LR) ;
    set Games_dup end = LR ;
    array NN[*] _numeric_   ;
    array CC[*] _character_ ;
    length _concat $ &cat_length _MD5 $ 16 ;
    _concat = catx (":", of NN[*], of CC[*]) ;
    _MD5 = MD5 (trim(_concat)) ;
    if h.check() = 0 then continue ;
    output ;
    h.add() ;
  end ;
run ;
