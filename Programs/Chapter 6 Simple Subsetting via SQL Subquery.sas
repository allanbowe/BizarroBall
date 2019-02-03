/* "Chapter 6 Simple Subsetting via SQL Subquery.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql ;
  create table Triples as
  select * from bizarro.Player_candidates
  where  Player_ID in
        (select Batter_ID from Dw.AtBats where Result = "Triple")
  and    Team_SK in (193) ;
quit ;
