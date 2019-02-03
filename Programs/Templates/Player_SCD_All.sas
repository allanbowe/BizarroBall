/* "Player_SCD_All.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.PLAYERS_SCD0
  (
   Player_ID num format=Z5. label = "Player ID",
   Team_SK num label = "Team Surrogate Key",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   Position_Code char(3) informat=$3. label "Batter Position",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R"
  );
quit;
 
data TEMPLATE.PLAYERS_SCD1;
 set TEMPLATE.PLAYERS_SCD0;
run;
 
proc sql;
 create table TEMPLATE.PLAYERS_SCD2
  (
   Player_ID num format=Z5. label = "Player ID",
   Team_SK num label = "Team Surrogate Key",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   Position_Code char(3) informat=$3. label "Batter Position",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R",
   Start_Date num format=YYMMDD10. label = "First Game Date",
   End_Date num format=YYMMDD10. label = "Last Game Date"
  );
 create table TEMPLATE.PLAYERS LIKE TEMPLATE.PLAYERS_SCD2(drop=Position_Code);
quit;
 
proc sql;
 create table TEMPLATE.PLAYERS_SCD3
  (
   Player_ID num format=Z5. label = "Player ID",
   Debut_Team_SK num label = "Debut Team Surrogate Key",
   Team_SK num label = "Current Team Surrogate Key",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R",
   Position_Code char(3) informat=$3. label "Batter Position"
  );
quit;
 
proc sql;
 create table TEMPLATE.PLAYERS_SCD3_FACTS
  (
   Player_ID num format=Z5. label = "Player ID",
   Team_SK num label = "Current Team Surrogate Key",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   First num label = "Games at First",
   Second num label = "Games at Second",
   Short num label = "Games at ShortStop",
   Third num label = "Games at Third",
   Left num label = "Games in Left",
   Center num label = "Games in Center",
   Right num label = "Games in Right",
   Catcher num label = "Games at Catcher",
   Pitcher num label = "Games at Pitcher",
   Pinch_Hitter num label = "Games as a Pinch Hitter"
  );
  create table template.PLAYERS_POSITIONS_PLAYED LIKE TEMPLATE.PLAYERS_SCD3_FACTS;
quit;
 
proc sql;
 create table TEMPLATE.PLAYERS_SCD6
  (
   Player_ID num format=Z5. label = "Player ID",
   Active num label = "Currently Active?",
   SubKey num label = "Secondary Key",
   Team_SK num label = "Team Surrogate Key",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   Position_Code char(3) informat=$3. label "Batter Position",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R",
   Start_Date num format=YYMMDD10. label = "First Game Date",
   End_Date num format=YYMMDD10. label = "Last Game Date"
  );
quit;
