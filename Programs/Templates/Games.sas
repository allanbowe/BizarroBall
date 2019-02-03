/* "Games.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.GAMES
  (
   Game_SK char(16) format=$HEX32. label = "Game Surrogate Key"
  ,Date num format=YYMMDD10. label = "Game Date"
  ,Time num format=TIMEAMPM8. label = "Game Time"
  ,Year num label = "Year"
  ,Month num label = "Month"
  ,DayOfWeek num Label = "Day of the Week"
  ,League_SK num label = "League"
  ,Home_SK num label = "Home Team Surrogate Key"
  ,Away_SK num label = "Away Team Surrogate Key"
  );
quit;
 
