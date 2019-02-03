/* "Pitches.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.PITCHES
  (
   Game_SK char(16) format=$HEX32. label = "Game Surrogate Key",
   Date num format=YYMMDD10. label = "Game Date",
   Team_SK num label = "Team Surrogate Key",
   Pitcher_ID num label = "Pitcher_ID",
   Pitcher_First_Name char(12) label = "Pitcher_First_Name",
   Pitcher_Last_Name char(12) label = "Pitcher_Last_Name",
   Pitcher_Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Pitcher_Throws char(1) informat=$1. label = "Throws L or R",
   Pitcher_Type char(3) label "Starter or Reliever",
   Inning num label = "Inning",
   Top_Bot char(1) label = "Which Half Inning",
   Result char(16) label = "Result of the At Bat",
   AB_Number num label = "At Bat Number in Game",
   Outs num label = "Number of Outs",
   Balls num label = "Number of Balls",
   Strikes num label = "Number of Strikes",
   Pitch_Number num label = "Pitch Number in the AB",
   Is_A_Ball num label = "Pitch is a Ball",
   Is_A_Strike num label ="Pitch is Strike",
   onBase num label ="Number of Men on Base"
  );
quit;
