/* "Runs.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.RUNS
  (
   Game_SK char(16) format=$HEX32. label = "Game Surrogate Key",
   Date num format=YYMMDD10. label = "Game Date",
   Batter_ID num label = "Batter ID",
   Inning num label = "Inning",
   Top_Bot char(1) label = "Which Half Inning",
   AB_Number num label = "At Bat Number in Game",
   Runner_ID num label = "ID of Runner Who Scored"
  );
quit;
