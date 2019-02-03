/* "Chapter 6 Subsetting via SQL Join with Simple Count.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql ;
 create table Triple_Count_SQL as
 select p.*, a.Count
 from   bizarro.Player_candidates p
      , (select Batter_ID, count(*) as Count
         from   Dw.AtBats
         where  Result = "Triple"
         group  Batter_ID) a
 where  a.Batter_ID = p.Player_ID
 and    p.Team_SK in (193)
 ;
quit ;
