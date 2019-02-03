/* "Chapter 6 Left Join via SQL.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql ;
  create table Triples_leftjoin_SQL as
  select p.*
       , b.date
       , b.Distance
       , b.Direction
  from   bizarro.Player_candidates (where = (Team_SK in (193))) P
  left join
         Dw.AtBats (where=(Result in ("Triple"))) B
  on     P.Player_ID = B.Batter_id
  ;
quit ;
