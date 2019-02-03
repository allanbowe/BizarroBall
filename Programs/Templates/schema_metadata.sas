/*******************************************************************
 Datalines for SCHEMA_METADATA dataset 
 Generated by %mp_ds2cards()
 Licensed under GNU, available on github.com/boemska/macrocore
********************************************************************/
data template.SCHEMA_METADATA ;
attrib 
hashTable                        length= $32 label="Member Name"
Column                           length= $32 label="Column Name"
Is_A_Key                         length= 8
;
infile cards dsd delimiter=',';
input 
   hashTable                        :$char.
   Column                           :$char.
   Is_A_Key
;
datalines4;
ATBATS,Game_SK,1
ATBATS,Batter_ID,.
ATBATS,Position_Code,.
ATBATS,Inning,.
ATBATS,Top_Bot,.
ATBATS,AB_Number,.
ATBATS,Result,.
ATBATS,Direction,.
ATBATS,Distance,.
ATBATS,Outs,.
ATBATS,Balls,.
ATBATS,Strikes,.
ATBATS,onFirst,.
ATBATS,onSecond,.
ATBATS,onThird,.
ATBATS,onBase,.
ATBATS,Left_On_Base,.
ATBATS,Runs,.
ATBATS,Is_An_AB,.
ATBATS,Is_An_Out,.
ATBATS,Is_A_Hit,.
ATBATS,Is_An_OnBase,.
ATBATS,Bases,.
ATBATS,Number_of_Pitches,.
CHAPTER10LOOKUPTABLES,hashTable,1
CHAPTER10LOOKUPTABLES,Column,.
CHAPTER10LOOKUPTABLES,Is_A_Key,.
CHAPTER10LOOKUPTABLES,datasetTag,.
CHAPTER10SPLITS,hashTable,1
CHAPTER10SPLITS,Column,.
CHAPTER10SPLITS,is_A_Key,.
CHAPTER9PARMFILE,hashTable,1
CHAPTER9PARMFILE,Column,.
CHAPTER9PARMFILE,is_A_Key,.
GAMES,Game_SK,1
GAMES,Date,.
GAMES,Time,.
GAMES,Year,.
GAMES,Month,.
GAMES,DayOfWeek,.
GAMES,League,.
GAMES,Home_SK,.
GAMES,Away_SK,.
LINEUPS,Game_SK,1
LINEUPS,Team_SK,.
LINEUPS,Batting_Order,.
LINEUPS,Player_ID,.
LINEUPS,Position_Code,.
LINEUPS,Bats,.
LINEUPS,Throws,.
PITCHES,Game_SK,1
PITCHES,Pitcher_ID,.
PITCHES,Pitcher_First_Name,.
PITCHES,Pitcher_Last_Name,.
PITCHES,Pitcher_Type,.
PITCHES,Inning,.
PITCHES,Top_Bot,.
PITCHES,Result,.
PITCHES,AB_Number,.
PITCHES,Outs,.
PITCHES,Balls,.
PITCHES,Strikes,.
PITCHES,Pitch_Number,.
PITCHES,Is_A_Ball,.
PITCHES,Is_A_Strike,.
PITCHES,onBase,.
PLAYERS,Player_ID,1
PLAYERS,Team_SK,.
PLAYERS,First_Name,.
PLAYERS,Last_Name,.
PLAYERS,Bats,.
PLAYERS,Throws,.
PLAYERS,Start_Date,.
PLAYERS,End_Date,.
PLAYERS_POSITIONS_PLAYED,Player_ID,1
PLAYERS_POSITIONS_PLAYED,First,.
PLAYERS_POSITIONS_PLAYED,Second,.
PLAYERS_POSITIONS_PLAYED,Short,.
PLAYERS_POSITIONS_PLAYED,Third,.
PLAYERS_POSITIONS_PLAYED,Left,.
PLAYERS_POSITIONS_PLAYED,Center,.
PLAYERS_POSITIONS_PLAYED,Right,.
PLAYERS_POSITIONS_PLAYED,Catcher,.
PLAYERS_POSITIONS_PLAYED,Pitcher,.
PLAYERS_POSITIONS_PLAYED,Pinch_Hitter,.
RUNS,Game_SK,1
RUNS,Inning,.
RUNS,Top_Bot,.
RUNS,AB_Number,.
RUNS,Runner_ID,.
;;;;
run;