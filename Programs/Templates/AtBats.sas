/* "AtBats.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.ATBATS
  (
   Game_SK char(16) format=$HEX32. label = "Game Surrogate Key",
   Date num format=YYMMDD10. label = "Game Date",
   Time num format=TIMEAMPM8. label = "Game Time",
   League num label = "League",
   Home_SK num label = "Home Team Surrogate Key",
   Away_SK num label = "Away Team Surrogate Key",
   Team_SK num label = "Team Surrogate Key",
   Batter_ID num label = "Batter ID",
   First_Name char(12) label = "Batter First Name",
   Last_Name char(12) label = "Batter Last Name",
   Position_Code char(3) label "Batter Position",
   Inning num label = "Inning",
   Top_Bot char(1) label = "Which Half Inning",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R",
   AB_Number num label = "At Bat Number in Game",
   Result char(16) label = "Result of the At Bat",
   Direction num label='Hit Direction',
   Distance num label = 'Hit Distance',
   Outs num label = "Number of Outs",
   Balls num label = "Number of Balls",
   Strikes num label = "Number of Strikes",
   onFirst num label = "ID of Runner on First",
   onSecond num label = "ID of Runner on Second",
   onThird num label = "ID of Runner on Third",
   onBase num label = "Number of Men on Base at Beginning of AB",
   Left_On_Base num label = "Number of Men Left on Base at End of AB",
   Runs num label = "Runs Scored",
   Is_An_AB num label = "Counts as an AB",
   Is_An_Out num label = "Is an Out",
   Is_A_Hit num label = "Is a Hit",
   Is_An_OnBase num label = "Counts as an On Base",
   Bases num label = "Number of Bases for the Hit",
   Number_of_Pitches num label = "Number of Pitches This AB"
  );
quit;
