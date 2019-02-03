/* "Player_Candidates.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table TEMPLATE.PLAYER_CANDIDATES
  (
   Player_ID num format=Z5. label = "Player ID",
   Team_SK num label = "Team Surrogate Key",
   First_Name char(12) informat=$12. label = "First Name",
   Last_Name char(12) informat=$12. label = "Last Name",
   Position_Code char(3) informat=$3. label = "Batter Position",
   Bats char(1) informat=$1. label = "Bats L, R or Switch",
   Throws char(1) informat=$1. label = "Throws L or R"
  );
quit;
