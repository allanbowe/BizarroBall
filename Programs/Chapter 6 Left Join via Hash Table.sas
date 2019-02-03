/* "Chapter 6 Left Join via Hash Table.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Triples_leftjoin_Hash (drop = Count) ;
 if _n_ = 1 then do ;
   dcl hash triple (
      multidata:"Y"
    , dataset:'Dw.AtBats(rename=(Batter_ID=Player_ID)
                         where=(Result="Triple"))'
      ) ;
   triple.defineKey ("Player_ID") ;
   triple.defineData ("Distance", "Direction") ;
   triple.defineDone () ;
   if 0 then set Dw.AtBats (keep=Distance Direction) ;
 end ;
 set Bizarro.Player_candidates ;
 where Team_SK in (193) ;
 call missing (Distance, Direction) ;
 do while (triple.do_over() = 0) ;
   Count = sum (Count, 1) ;
   output ;
 end ;
 if not Count then output ;
run ;
