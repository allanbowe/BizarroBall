/* "LineUps.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.LINEUPS
  (
   Game_SK char(16) format=$HEX32. label = "Game Surrogate Key",
   Date num format=YYMMDD10. label = "Game Date",
   Team_SK num label = "Team Surrogate Key",
   Batting_Order num label = "Lineup Position",
   Player_ID num format=Z5. label = "Player ID",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   Position_Code char(3) informat=$3.  label "Position",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R"
  );
 create index LineUp on template.LINEUPS(Game_SK,Team_SK);
quit;
