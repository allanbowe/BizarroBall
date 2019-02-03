/* "Chapter 11 MD5 Key Reduction Unduplication.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let cat_length = 34 ;
 
data First_scores_MD5 (drop = _:) ;
  if _n_ = 1 then do ;
    dcl hash h() ;
    h.defineKey  ("_MD5") ;
    h.defineData ("_N_") ;
    h.defineDone () ;
    dcl hiter ih ("h") ;
 end ;
 do until (LR) ;
   set dw.Runs end = LR ;
   length _concat $ &cat_length _MD5 $ 16 ;
   _concat = catx (":", Game_SK, Runner_ID) ;
   _MD5 = MD5 (_concat) ;
   if h.check() = 0 then continue ;
   output ;
   h.add() ;
 end ;
run ;
