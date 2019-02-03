/* "Chapter 6 Subsetting via Hash Table with Simple Count.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Triple_Count_Hash ;
 if _n_ = 1 then do ;
   dcl hash triple (
      multidata:"Y"
    , dataset:'Dw.AtBats(rename=(Batter_ID=Player_ID)
                         where=(Result="Triple"))'
      ) ;
   triple.defineKey ("Player_ID") ;
 * triple.defineData ("Player_ID") ;
   triple.defineDone () ;
 end ;
 set Bizarro.Player_candidates ;
 where Team_SK in (193) ;
 if triple.check() = 0 ;
 do Count = 1 by 1 while (triple.do_over() = 0) ;
 end ;
run ;
