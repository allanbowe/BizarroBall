/**
  @file
  @brief Auto-generated file
  @details The `build.sh` file in the https://github.com/allanbowe/bizarroball repo
    is used to create this file.
  @author Allan Bowe (derivative of work by Don Henderson and Paul Dorfman)
  ///@cond INTERNAL
**/

%let defaultroot=%sysfunc(pathname(work)); /* change to permanent path, sasuser maybe */
%*let defaultroot = /folders/myfolders/BizarroBall; /* use this for the University Edition */

/* some conditional logic as root may have been predefined */
%global root; 
%let root=%sysfunc(coalescec(&root,&defaultroot));

options dlcreatedir;
libname bizarro "&root/Data";
libname DW "&root/DW";
libname template "&root/Data/Template";

/* SCD End Date - Used in Chapter 7 */
%let SCD_End_Date = '31DEC9999'd;

/* The following macro variables are only used in the programs/macros
   to generate the sample Bizarro Ball data.
*/

/* Parameters for creating the data */
%let nTeamsPerLeague = 16;
%let seasonStartDate = 20MAR2017;
%let nWeeksSeason = %eval((&nTeamsPerLeague-1)*2);
%let nPlayersPerTeam = 25;
%let nBattersPerGame = 9;
 
/* Random Number Seeds */
%let seed1  = 54321;  /* used in S0100 GenerateTeams.sas */
%let seed2  = 98765;  /* used in S0300 GeneratePlayerCandidates.sas */
%let seed3  = 76543;  /* used in S0300 GeneratePlayerCandidates.sas */
%let seed4  = 11;     /* used in S0500 GenerateSchedule.sas */
%let seed5  = 9887;   /* used in macro generatelinesups.sas */
%let seed6  = 9973;   /* used in macro generatepitchandpadata.sas */
%let seed7  = 101;    /* used in macro generatepitchandpadata.sas */
%let seed8  = 10663;  /* used in macro generatepitchandpadata.sas */
%let seed9  = 10753;  /* used in macro generatepitchandpadata.sas */
%let seed10 = 98999;  /* used in S0300 GeneratePlayerCandidates.sas */
%let seed11 = 99223;  /* used in S0300 GeneratePlayerCandidates.sas */


/* now include macros & datalines */
/* "createhash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%macro createHash
       (lib = dw
       ,hashTable = hashTable
       ,metaData = template.Schema_Metadata
       );
 
 if 0 then set template.&hashTable;
 dcl hash _&hashTable(dataset:"&lib..&hashtable"
                     ,multidata:"Y"
                     ,ordered:"A");
 lr = 0;
 do while(lr=0);
    set &metadata end=lr;
    where upcase(hashTable) = "%upcase(&hashTable)";
    if is_a_key then _&hashTable..DefineKey(Column);
    _&hashTable..DefineData(Column);
 end;
 _&hashTable..DefineDone();
 
%mend createHash;
/* "generatelineups.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%macro generateLineUps
       (from =
       ,nweeks =
       );
 
 %local to;
 %let from = %sysfunc(inputn(&from,date9.));
 %let to = %eval(&from + &nweeks*7 - 1);
 
 %do date = &from %to &to;
 
    data _null_;
 
     retain Date &Date;
     if 0 then
     do;  /* define vars to PDV */
        set template.LineUps bizarro.Positions_Snowflake;
        Away_SK = Team_SK;
        Home_SK = Team_SK;
     end; /* define vars to PDV */
 
	 /* load hash table with number of starters for each position */
     declare hash positions(dataset:"bizarro.Positions");
     positions.defineKey("Position_Grp_SK");
     positions.defineData("Position_Grp_SK","Position_Code","Count","Starters");
     positions.defineDone();
     declare hiter positionIter("positions");
 
     declare hash positions_snowflake(dataset:"bizarro.Positions_Snowflake",ordered:"A",multidata:"Y");
     positions_snowflake.defineKey("Position_Grp_FK");
     positions_snowflake.defineData("Position_Grp_FK","Position_Code");
     positions_snowflake.defineDone();
 
     declare hash LineUp(multidata:"Y");
     rc = LineUp.defineKey("Game_SK","Team_SK");
     rc = LineUp.defineData("Game_SK","Team_SK","Date","Batting_Order","Player_ID","First_Name","Last_Name","Position_Code","Bats","Throws");
     rc = LineUp.defineDone();
 
     declare hash players(dataset:"bizarro.Player_Candidates(where=(Team_SK))",ordered:"A",multidata:"Y");
     rc = players.defineKey("Team_SK","Position_Code");
     rc = players.defineData("Team_SK","Player_ID","First_Name","Last_Name","Bats","Throws");
     rc = players.defineDone();
 
     do while (lr = 0);
        set bizarro.trades end = lr;
        where trade_date le &date;
        do while(players.do_over(Key:_team_sk,Key:_Position_Code) = 0);
           if player_id = traded_id then
           do;  /* player traded - delete and re-add */
              players.removeDup();
              team_sk = traded_to;
              Position_Code = _Position_Code;
              players.add();
              leave;
           end;
        end;
     end;
 
     declare hash games(dataset:"bizarro.Games(where=(date=&date))",multidata:"Y");
     rc = games.defineKey("Date");
     rc = games.defineData("Game_SK","Away_SK","Home_SK");
     rc = games.defineDone();
 
     games_rc = games.find(Key:&date);
     do while (games_rc = 0);
        do team_sk = away_sk, home_sk;
           rc = positionIter.first();
           P_Grp = Position_Code;
           grp_rc = positions_snowflake.find(Key:Position_Grp_SK);
           do while(rc=0);
              prc = players.find(Key:Team_SK,Key:P_grp);
              do while(prc = 0);
                 Batting_Order = uniform(&seed5*&date);
                 if divide(Starters,Count) gt Batting_Order then
                 do;  /* select this player */
                    if position_code = "SP" then Batting_Order = 9;
                    rc = LineUp.add();
                    if grp_rc = 0 then grp_rc = positions_snowflake.find_next(Key:Position_Grp_SK);
                    Starters + (-1);            /* need one less player */
                 end; /* select this player */
                 else if position_code ne "SP" then
                 do;  /* pinch hitters and relief pitchers */
                    _position_code = position_code;
                    if position_code = 'RP' then Batting_Order = 1e6;
                    else
                    do;/* assign as a pinch hitter for the pitcher */
                       Batting_Order + 9;
                       Position_Code = 'PH';
                    end; /* assign as a pinch hitter for the pitcher */
                    LineUp.add();
                    position_code = _position_code;
                 end; /* pinch hitters and relief pitchers */
                 Count + (-1);                  /* regardless have one less player */
                 prc = players.find_next(Key:Team_SK,Key:P_grp);
              end;
              *if Position_Code = 'UT' then
              do;  /* add utility players as PHers */;
               *     Batting_Order = 9 + uniform(&seed5*&date);
                    *Position_Code = 'PH';
                *    LineUp.add();
              *end; /* add utility players as PHers */;
              rc=positionIter.next();
              P_Grp = Position_Code;
              grp_rc = positions_snowflake.find(Key:Position_Grp_SK);
           end;
        end;
        games_rc = games.find_next();
     end;
     LineUp.output(dataset:"Lineups");
     stop;
    run;
 
    proc sort data = lineups out = lineups;
     by game_sk team_sk batting_order;
    run;
 
    %if %sysfunc(exist(bizarro.LineUps)) %then
    %do;  /* delete existing rows for these games */
       proc sql;
        delete from bizarro.Lineups
        where Game_SK in (select distinct Game_SK from Lineups);
       quit;
    %end; /* delete existing rows for these games */
    %else
    %do;  /* create the initial data set */
       data bizarro.LineUps;
	    set Lineups(obs=0);
       run;
    %end; /* create initial data set */
 
    data bizarro.LineUps(index=(LineUp=(Game_SK Team_SK)));
	 set bizarro.Lineups
	     LineUps(in = new);
     drop Order;
     by game_sk team_sk;
     if first.team_sk then Order=0;
     Order+1;
     if batting_order ne int(batting_order) and new then batting_order = min(Order,9);
    run;
 %end;
%mend generateLineUps;
/* "generatepitchandpadata.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%macro generatePitchAndPAData
       (from =
       ,nweeks =
       );
 
 %local to;
 %let from = %sysfunc(inputn(&from,date9.));
 %let to = %eval(&from + &nweeks*7 - 1);
 
 %do date = &from %to &to;
 
    data _null_;
 
     if 0 then set template.AtBats template.Pitches template.Runs;
 
     retain Inning 1 Pitcher_ID . Date &date;
     length data_to_load $16;
     array runners(*) onFirst onSecond onThird;
 
     if _n_ = 1 then
     do;  /* define the needed hash tables */
 
        declare hash pitch_dist(ordered:"A");
        rc = pitch_dist.DefineKey("Index");
        rc = pitch_dist.DefineData("Index","Result","AB_Done","Is_An_Ab","Is_An_Out","Is_A_Hit","Is_An_OnBase"
                                  ,"Bases","Runners_Advance_Factor","Pitch_Distribution_SK");
        rc = pitch_dist.DefineDone();
        lr = 0;
        do until(lr);
           set bizarro.pitch_distribution end=lr;
           do Index = From to To;
              rc =pitch_dist.add();
           end;
        end;
        lr=0;
 
        declare hash hit_distance(dataset:"bizarro.hit_distance"
                                       || "(rename=(Pitch_Distribution_FK=Pitch_Distribution_SK))");
        rc = hit_distance.DefineKey("Pitch_Distribution_SK");
        rc = hit_distance.DefineData("MinDistance","MaxDistance");
        rc = hit_distance.DefineDone();
 
 
        declare hash batters(ordered:"A",multidata:"Y");
        rc = batters.DefineKey("Top_Bot","Batting_Order");
        rc = batters.DefineData("Team_SK","Top_Bot","Batter_ID","First_Name","Last_Name","Position_Code","Bats","Throws");
        rc = batters.DefineDone();
 
        declare hash pitchers(ordered:"D",multidata:"Y");
        rc = pitchers.DefineKey("Top_Bot");
        rc = pitchers.DefineData("Team_SK","Top_Bot","Pitcher_ID","First_Name","Last_Name","Position_Code","Pitcher_Bats","Pitcher_Throws");
        rc = pitchers.DefineDone();
 
        if exist("bizarro.Runs")
                 then data_to_load = "bizarro.Runs";
        else data_to_load = "template.Runs";
        declare hash facts_runs(dataset:data_to_load
                               ,ordered:"A"
                               ,multidata:"Y");
        facts_runs.DefineKey("Date","Game_SK");
        facts_runs.DefineData("Game_SK","Date","Batter_ID"
                             ,"Inning","Top_Bot"
                             ,"AB_Number","Runner_ID");
        facts_runs.DefineDone();
 
        if exist("bizarro.Pitches") then data_to_load = "bizarro.Pitches";
        else data_to_load = "template.Pitches";
        declare hash facts_pitches(dataset:data_to_load,ordered:"A",multidata:"Y");
        facts_pitches.DefineKey("Date","Game_SK");
        facts_pitches.DefineData("Game_SK","Date","Team_SK","Pitcher_ID","Pitcher_First_Name","Pitcher_Last_Name"
                                ,"Pitcher_Bats","Pitcher_Throws","Pitcher_Type","Inning","Top_Bot","Result","AB_Number","Outs"
                                ,"Balls","Strikes","Pitch_Number","Is_A_Ball","Is_A_Strike","onBase");
        facts_pitches.DefineDone();
 
        if exist("bizarro.AtBats") then data_to_load = "bizarro.AtBats";
        else data_to_load = "template.AtBats";
        declare hash facts_atbats(dataset:data_to_load,ordered:"A",multidata:"Y");
        facts_atbats.DefineKey("Date","Game_SK");
        facts_atbats.DefineData("Game_SK","Date","Time","League","Away_SK","Home_SK","Team_SK"
                               ,"Batter_ID","First_Name","Last_Name","Position_Code","Inning"
                               ,"Top_Bot","Bats","Throws","AB_Number","Result","Direction","Distance"
                               ,"Outs","Balls","Strikes","onFirst","onSecond","onThird","onBase"
                               ,"Left_On_Base","Runs","Is_An_AB","Is_An_Out","Is_A_Hit","Is_An_OnBase"
                               ,"Bases","Number_of_Pitches");
        facts_atbats.DefineDone();
 
     end; /* define the needed hash tables */
 
     if lr then
     do;  /* output the updated fact tables */
        facts_runs.output(dataset:"bizarro.Runs");
        facts_pitches.output(dataset:"bizarro.Pitches");
        facts_atbats.output(dataset:"bizarro.AtBats");
     end; /* output the updated fact tables */
 
     set bizarro.games end=lr;
     where date=&date;
     League = League_SK;  /* fix/hack for missed rename */
 
     if game_sk ne lag(game_sk) then
     do;  /* delete existing rows for this game */
        if facts_runs.check() = 0 then facts_runs.remove();
        if facts_pitches.check() = 0 then facts_pitches.remove();
        if facts_atbats.check() = 0 then facts_atbats.remove();
     end; /* delete existing rows for this game */
 
     /* load the batter data for this game */
     rc = batters.clear();
     rc = pitchers.clear();
     Top_Bot = "T";
     do team_sk = away_sk, home_sk;
        do until(_iorc_ ne 0);
           set bizarro.LineUps key = LineUp;
           if _iorc_ = 0 then
           do;  /* row found and read */
              rc = batters.add(Key:Top_Bot,Key:Batting_Order,Data:Team_SK,Data:Top_Bot,Data:Player_ID,Data:First_Name,Data:Last_Name,Data:Position_Code,Data:Bats,Data:Throws);
              if Position_Code in ("SP" "RP") then rc = pitchers.add(Key:Top_Bot,Data:Team_SK,Data:Top_Bot,Data:Player_ID,Data:First_Name,Data:Last_Name,Data:Position_Code,Data:Bats,Data:Throws);
           end; /* row found and read */
        end;
        Top_Bot = "B";
     end;
 
     Team_SK = .;
 
     _error_ = 0;  /* suppress the error message when the indexed read failed as expected */
 
     array _halfInning(2) ab_t ab_b;
     call missing(ab_t,ab_b);
 
     do Inning = 1 to 9;
        ab_index = 0;
        do Top_Bot = "T", "B";
           ab_index + 1;
           rc = pitchers.find(key:Top_Bot);
 
           rc = pitchers.has_next(result:not_last);
           if inning ge 6 and not_last then
           do;
              rc=pitchers.removeDup();
              pitchers.find(key:Top_Bot);
           end;
 
           Pitcher_First_Name = First_Name;
           Pitcher_Last_Name = Last_Name;
           Pitcher_Type = Position_Code;
           outs = 0;
           call missing(onFirst,onSecond,onThird);
           do until(outs=3);
              Is_An_Out = .;
              Balls = 0;
              Strikes = 0;
              Pitch_Number = 0;
              _halfInning(ab_index) + 1;
              AB_Number = _halfInning(ab_index);
              rc = batters.find(key:Top_Bot,Key:mod(AB_Number-1,&nBattersPerGame)+1);
 
           rc = batters.has_next(result:not_last);
           if mod(AB_Number,&nBattersPerGame)= 0 and inning ge 6 and not_last then
           do;
              rc=batters.removeDup();
              batters.find(key:Top_Bot,Key:mod(AB_Number-1,&nBattersPerGame)+1);
           end;
 
              do until(AB_Done);
                 Pitch_Number+1;
                 Index = ceil(100*uniform(&seed6*&date));
                 rc = pitch_dist.find();
                 if not AB_Done then
                 do;  /* continue the Plate Appearance */
                    call missing(Is_A_Ball,Is_A_Strike);
                    if Result = "Ball" then Is_A_Ball = 1;
                    else if find(Result,"strike","i") then Is_A_Strike = 1;
                    else if Result = "Foul" and Strikes lt 2 then Is_A_Strike = 1;
                    Balls + Is_A_Ball;
                    Strikes + Is_A_Strike;
                    facts_pitches.add();
                    AB_Done = (Balls = 4 or Strikes = 3);
                    if Balls = 4 then
                    do;  /* set needed values for a walk */
                       Result = "Walk";
                       call missing(Is_An_AB,Is_An_Out,Is_A_Hit);
                       Bases = 1;
                       Runners_Advance_Factor = 1;
                       Is_An_OnBase = 1;
                    end; /* set needed values for a walk */
                    else if Strikes = 3 then
                    do;  /* set needed values for a strikeout */
                       Result = "Strikeout";
                       Is_An_AB = 1;
                       Is_An_Out = 1;
                       Is_An_OnBase = 0;
                       call missing(Is_A_Hit,Bases);
                    end; /* set needed values for a walk */
                 end; /* continue the Plate Appearance */
                 else facts_pitches.add();
                 if ab_done then
                 do;  /* create needed result fields */
                    call missing(MinDistance,MaxDistance,Direction,Distance);
                    if hit_distance.find()=0 then
                    do;  /* calculate direction and distance */
				       Direction = ceil(18*uniform(&seed7*&date));
				       Distance = MinDistance + ceil((MaxDistance-MinDistance)*uniform(&seed8*&date));
                    end; /* calculate direction and distance */
                    onBase = 3 - nmiss(of runners(*));
                    Runs = 0;
                    if Bases then
                    do;  /* advance runners */
                       Left_On_Base = 0;
                       Advance = Bases + (Runners_Advance_Factor > uniform(&seed9*Date));
                       do i = dim(runners) to 1 by -1;
                          if runners(i) then
                          do;  /* advance runner on this base */
                             if i+Advance ge 4 then
                             do;  /* runners scored */
                                Runs + 1;
                                Runner_ID = runners(i);
                                facts_runs.add();
                             end; /* runners scored */
                             else runners(i+Advance) = runners(i);
                             runners(i) = .;
                          end; /* advance runner on this base */
                       end;
                       if bases lt 4 then runners(bases) = batter_id;
                       else
                       do;  /* runners scored */
                          Runs + 1;
                          Runner_ID = Batter_ID;
                          facts_runs.add();
                       end; /* runners scored */
                    end; /* advance runners */
                    else Left_On_Base = onBase;
                    Number_of_Pitches = Pitch_Number;	
                    facts_atbats.add();
                    outs + Is_An_Out;
                 end; /* create needed result fields */
              end; /* AB loop */
           end; /* Outs Loop */
        end; /* Innings Loop */
     end; /* cheating a bit here - discuss with Paul */
    run;
 %end;
%mend generatePitchAndPAData;
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
/* "Chapter 5 GenerateTeams.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data bizarro.teams;
 /* Select team names from 100 most popular team names.
    Source: http://mascotdb.com/lists.php?id=5
 */
 keep League_SK Team_SK Team_Name;
 keep League; /* fix for rename issue found post-publication */ 
 label League_SK = "League Surrogate Key"
       Team_SK = "Team Surrogate Key"
       Team_Name = "Team Name"
 ;
 retain League_SK . Team_SK 100;
 if _n_ = 1 then
 do;  /* create hash table */
    declare hash teams();
    rc = teams.defineKey("Team_Name");
    rc = teams.defineData("Team_SK","Team_Name");
    rc = teams.defineDone();
 end; /* create hash table */
 infile datalines eof=lr;
 input Team_Name $16.;
 Team_SK + ceil(uniform(&seed1)*4);
 rc = teams.add();
 return;
 lr:
 declare hiter teamIter("teams");
 do i = 1 to 2*&nTeamsPerLeague;
    rc = teamIter.next();
    League_SK = int((i-1)/&nTeamsPerLeague) + 1;
    League = League_SK;  /* fix for rename issue found post-publication */
    output;
 end;
datalines;
Eagles
Tigers
Bulldogs
Panthers
Wildcats
Warriors
Lions
Indians
Cougars
Knights
Mustangs
Falcons
Trojans
Cardinals
Vikings
Pirates
Raiders
Rams
Spartans
Bears
Hornets
Patriots
Hawks
Crusaders
Rebels
Bobcats
Saints
Braves
Blue Devils
Titans
Wolverines
Jaguars
Wolves
Dragons
Pioneers
Chargers
Rockets
Huskies
Red Devils
Yellowjackets
Chiefs
Stars
Comets
Colts
Lancers
Rangers
Broncos
Giants
Senators
Bearcats
Thunder
Royals
Storm
Cowboys
Cubs
Cavaliers
Golden Eagles
Generals
Owls
Buccaneers
Hurricanes
Bruins
Grizzlies
Gators
Bombers
Red Raiders
Flyers
Lakers
Miners
Redskins
Coyotes
Longhorns
Greyhounds
Beavers
Yellow Jackets
Outlaws
Reds
Highlanders
Sharks
Oilers
Jets
Dodgers
Mountaineers
Red Sox
Thunderbirds
Blazers
Clippers
Aces
Buffaloes
Lightning
Bluejays
Gladiators
Mavericks
Monarchs
Tornadoes
Blues
Cobras
Bulls
Express
Stallions
;
data bizarro.leagues;
 label League_SK = "League Surrogate Key"
       League = "League"
 ;
 League_SK = 1;
 League = 'Eastern';
 output;
 League_SK = 2;
 League = 'Western';
 output;
run;
/* "Chapter 5 GeneratePositionsDimensionTable.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 infile datalines eof=readall;
 /* Hash Object as an in memory table */
 if _n_ = 1 then
 do;  /* define just once */
    declare hash positions(ordered:"a");
    positions.defineKey("Position_Grp_SK");
    positions.defineData("Position_Grp_SK","Position_Code","Position","Count","Starters");
    positions.defineDone();
 end; /* define just once */
 informat Position_Code $3. Position $17. Count Starters 8.;
 label Position_Grp_SK = "Position Group Surrogate Key"
       Position_Code = "Position Code"
       Position = "Position Description"
       Count = "Number of Players"
       Starters = "Number of Starters"
 ;
 input Position_Code Position & Count Starters;
 Position_Grp_SK + 1;
 positions.add(); /* could also use positions.add() or positions.ref() */
 return;
 readall:
    /* output a sorted version of our table */
    positions.output(dataset:"Bizarro.Positions");
    return;
 datalines;
SP  Starting Pitcher   4 1
RP  Relief Pitcher     6 0
C   Catcher            2 1
CIF Corner Infielder   3 2
MIF Middle Infielder   3 2
COF Corner Outfielder  3 2
CF  Center Fielder     2 1
UT  Utility            2 0
;
data  _null_;
 infile datalines eof=readall;
 /* Hash Object as an in memory table */
 if _n_ = 1 then
 do;  /* define just once */
    declare hash positions(ordered:"a");
    positions.defineKey("Position_SK");
    positions.defineData("Position_SK","Position_Grp_FK","Position_Code","Position");
    positions.defineDone();
 end; /* define just once */
 informat Position_Grp_FK 8. Position_Code $3. Position $17.;
 label Position_SK = "Position Surrogate Key"
       Position_Grp_FK = "Position Group Surrogate Key"
       Position_Code = "Position Code"
       Position = "Position Description"
 
 ;
 input Position_Grp_FK Position_Code Position &;
 Position_SK + 1;
 positions.add(); /* could also use positions.add() or positions.ref() */
 return;
 readall:
    /* output a sorted version of our table */
    positions.output(dataset:"Bizarro.Positions_Snowflake");
    return;
 datalines;
4 1B First Baseman
4 3B Third Baseman
5 2B Second Baseman
5 SS Shortstop
6 LF Left Fielder
6 RF Right Fielder
;
/* "Chapter 5 GeneratePlayerCandidates.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data first_names;
 /* SRC: https://www.ssa.gov/oact/babynames/decades/century.html */
 infile datalines;
 informat First_Name $12.;
 input First_Name $;
 First_Name = propcase(First_Name);
 n + 1;
 datalines;
James
John
Robert
Michael
William
David
Richard
Joseph
Thomas
Charles
Christopher
Daniel
Matthew
Anthony
Donald
Mark
Paul
Steven
George
Kenneth
Andrew
Joshua
Edward
Brian
Kevin
Ronald
Timothy
Jason
Jeffrey
Ryan
Gary
Jacoby
Nicholas
Eric
Stephen
Jonathan
Larry
Scott
Frank
Justin
Brandon
Raymond
Gregory
Samuel
Benjamin
Patrick
Jack
Alexander
Dennis
Jerry
Tyler
Aaron
Henry
Douglas
Peter
Jose
Adam
Zachary
Walter
Nathan
Harold
Kyle
Carl
Arthur
Gerald
Roger
Keith
Jeremy
Lawrence
Terry
Sean
Albert
Joe
Christian
Austin
Willie
Jesse
Ethan
Billy
Bruce
Bryan
Ralph
Roy
Jordan
Eugene
Wayne
Louis
Dylan
Alan
Juan
Noah
Russell
Harry
Randy
Philip
Vincent
Gabriel
Bobby
Johnny
Howard
;
data last_names;
 /* SRC: http://names.mongabay.com/most_common_surnames.htm */
 infile datalines;
 informat Last_Name $12.;
 input Last_Name $;
 Last_Name = propcase(Last_Name);
 n + 1;
datalines;
SMITH
JOHNSON
WILLIAMS
JONES
BROWN
DAVIS
MILLER
WILSON
MOORE
TAYLOR
ANDERSON
THOMAS
JACKSON
WHITE
HARRIS
MARTIN
THOMPSON
GARCIA
MARTINEZ
ROBINSON
CLARK
RODRIGUEZ
LEWIS
LEE
WALKER
HALL
ALLEN
YOUNG
HERNANDEZ
KING
WRIGHT
LOPEZ
HILL
SCOTT
GREEN
ADAMS
BAKER
GONZALEZ
NELSON
CARTER
MITCHELL
PEREZ
ROBERTS
TURNER
PHILLIPS
CAMPBELL
PARKER
EVANS
EDWARDS
COLLINS
STEWART
SANCHEZ
MORRIS
ROGERS
REED
COOK
MORGAN
BELL
MURPHY
BAILEY
RIVERA
COOPER
RICHARDSON
COX
HOWARD
WARD
TORRES
PETERSON
GRAY
RAMIREZ
JAMES
WATSON
BROOKS
KELLY
SANDERS
PRICE
BENNETT
WOOD
BARNES
ROSS
HENDERSON
COLEMAN
JENKINS
PERRY
POWELL
LONG
PATTERSON
HUGHES
FLORES
WASHINGTON
BUTLER
SIMMONS
FOSTER
GONZALES
BRYANT
ALEXANDER
RUSSELL
GRIFFIN
DIAZ
HAYES
;
data _null_;
 if 0 then set template.player_candidates;
 retain Player_ID 10000 Team_SK 0;
 declare hash positionsDist();
 rc = positionsDist.defineKey("Index");
 rc = positionsDist.defineData("Index","Position_Code","Count");
 rc = positionsDist.defineDone();
 lr = 0;
 Index = 0;
 do until(lr);
    set bizarro.positions end=lr;
    do i = 1 to Count;
       Index + 1;
       rc = positionsDist.add();
    end;
 end;
 rc = positionsDist.output(dataset:"positions");
 
 declare hash fname(dataset: "first_names");
 rc = fname.defineKey("First_Name");
 rc = fname.defineData("First_Name");
 rc = fname.defineDone();
 declare hiter first_iter("fname");
 
 declare hash lname(dataset: "last_names");
 rc = lname.defineKey("Last_Name");
 rc = lname.defineData("Last_Name");
 rc = lname.defineDone();
 declare hiter last_iter("lname");
 
 declare hash players();
 rc = players.defineKey("Arbtrary","First_Name","Last_Name");
 rc = players.defineData("Player_ID","Team_SK","First_Name","Last_Name"
                        ,"Position_Code","Bats","Throws");
 rc = players.defineDone();
 
 Arbtrary = 0;
 do frc = first_iter.first() by 0 while(frc = 0);
    do lrc = last_iter.first() by 0 while(lrc = 0);
       Arbitrary + 1;
       positionsDist.find(Key:ceil(uniform(&seed2)*&nPlayersPerTeam));
       Player_ID + ceil(uniform(&seed3)*9);
       random = uniform(&seed10);
       if random le .1 then Bats = "S";
       else if random le .35 then Bats = "L";
       else Bats = "R";
       if uniform(&seed11) le .3 then Throws = "L";
       else Throws = "R";
       players.add();
       lrc = last_iter.next();
    end;
    frc = first_iter.next();
 end;
 players.output(dataset:"bizarro.player_candidates");
 
run;/* "Chapter 5 AssignPlayersToTeams.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data positions;
 set bizarro.positions;
 retain DummyKey 1;
 drop position;
run;
 
data _null_;
 
 if 0 then set template.player_candidates;
 retain Player_ID 10000 Start_Date "01MAR2017"d End_Date &SCD_End_Date;
 format Player_ID z5. Start_Date End_Date mmddyy10.;
 informat Start_Date End_Date yymmdd10.;
 
 /* load the available players */
 declare hash available(dataset:"bizarro.player_candidates",multidata:"yes");
 rc = available.defineKey("Position_Code");
 rc = available.defineData("Player_ID","Team_SK","First_Name","Last_Name"
                          ,"Position_Code","Bats","Throws");
 rc = available.defineDone();
 
 /* load the hash table of positions */
 declare hash positions(dataset:"positions",multidata:"yes");
 rc = positions.defineKey("DummyKey");
 rc = positions.defineData("Position_Code","Count");
 rc = positions.defineDone();
 
 /* load the list of teams */
 declare hash teams(dataset:"Bizarro.teams");
 rc = teams.defineKey("Team_SK");
 rc = teams.defineDone();
 declare hiter teams_iter("teams");
 
 DummyKey = 1;
 pos_rc = positions.find();
 avail_rc = available.find();
 do until(pos_rc);
    teams_rc = teams_iter.first();
    do until(teams_rc);
       Team = Team_SK;
       do i = 1 to Count;
          Team_SK = Team;
          available.replaceDup();
          avail_rc = available.find_next();
       end;
       teams_rc = teams_iter.next();
    end;
    pos_rc = positions.find_next();
    avail_rc = available.find();
 end;
 rc = available.output(dataset:"bizarro.player_candidates");
run;
  
data bizarro.trades;
 format trade_date yymmdd10.;
 input trade_date yymmdd10. traded_id _position_code $3. _team_sk traded_to;
datalines;
2017/06/23 10090 SP  269 115
2017/06/23 10753 SP  115 269
2017/07/26 10103 COF 171 228
2017/07/26 10760 COF 228 171
2017/08/30 10145 CF  193 130
2017/08/30 10732 CF  130 193
;
 
/* "Chapter 5 GenerateSchedule.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 retain Team_SK Team1_SK Team2_SK .; /* define hash data items */
 format Date yymmdd10.;
 
 declare hash team1(dataset:"bizarro.teams(rename=(Team_SK=Team1_SK))",multidata:"y");
 rc = team1.defineKey("League_SK");
 rc = team1.defineData("League_SK","Team1_SK");
 rc = team1.defineDone();
 
 declare hash team2(dataset:"bizarro.teams(rename=(Team_SK=Team2_SK))",multidata:"y");
 rc = team2.defineKey("League_SK");
 rc = team2.defineData("League_SK","Team2_SK");
 rc = team2.defineDone();
 
 declare hash matchUps(multidata:"y");
 rc = matchUps.defineKey("League_SK");
 rc = matchUps.defineData("League_SK","Team1_SK","Team2_SK");
 rc = matchUps.defineDone();
 
 declare hash used();
 rc = used.defineKey("League_SK","Team_SK");
 rc = used.defineData("League_SK","Team_SK");
 rc = used.defineDone();
 
 declare hash schedule();
 rc = schedule.defineKey("League_SK","Team1_SK","Team2_SK");
 rc = schedule.defineData("League_SK","Team1_SK","Team2_SK","Date","Home");
 rc = schedule.defineDone();
 
 do League_SK = 1 to 2;                     /* loop thru Leagues */
    Team1_rc = team1.find();
    do while(Team1_rc=0);                /* loop thru Team1 Teams */
       Team2_rc = team2.find();
       do while(Team2_rc=0);             /* loop thru Team2 Teams for each Team1 team */
          if Team2_SK ne Team1_SK then
          do;
             addrc = matchUps.add();
          end;
          Team2_rc = team2.find_next();
       end;                              /* loop thru Team2 Teams for each Team1 team */
       Team1_rc = team1.find_next();
    end;                                 /* loop thru Team1 Teams */
 end;                                    /* loop thru Leagues */
 
 do League_SK = 1 to 2;                             /* loop thru Leagues */
    Date = "&seasonStartDate"d - 3;
    do Combo = 1 to &nWeeksSeason;             /* create the matchup sets */
       if mod(combo,2) = 1 then Date + 3;
       else Date + 4;
       games = 0;
       matchUps_rc = matchUps.find();
       do while(matchUps_rc = 0 and games lt &nTeamsPerLeague/2);
          if    used.check(key:League_SK,key:Team1_SK) ne 0
            and used.check(key:League_SK,key:Team2_SK) ne 0
          then
          do;  /* combinations not yet used */
             Home = ceil(uniform(&seed4)*2);
             if schedule.add() = 0 then
             do;  /* add to schedule */
                games + 1;
                rc = used.add(Key:League_SK,Key:Team1_SK,Data:League_SK,Data:Team1_SK);
                rc = used.add(Key:League_SK,Key:Team2_SK,Data:League_SK,Data:Team1_SK);
             end; /* add to schedule */
          end; /* combinations not yet used */
          matchUps_rc = matchUps.find_next();
       end;
       used.clear();                             /* loop thru matchups */
    end;/* loop thru Leagues */
 end;
 schedule.output(dataset:"Games");
 stop;
run;
 
proc sort data = games out = games;
 by League_SK Date;
run;
 
data bizarro.games;
 if 0 then set template.games;
 drop Team1_SK Team2_SK Home D;
 format Time Timeampm8.;
 set games;
 League = League_SK; /* fix for rename issue found post-publication */
 D = Date;
 retain D;
 array _homeaway team1_sk team2_sk;
 Home_SK = _homeaway(Home);
 Away_SK = _homeaway(3-Home);
 do Date = D to D+2;
    Year = Year(Date);
    Month = Month(Date);
    DayOfWeek = weekday(Date);
    if DayOfWeek = 5 then Time = "16:00"t;
    else if DayOfWeek = 1 then Time = "13:00"t;
    else time = "19:00"t;
    Game_SK = md5(catx(":",League_SK,Away_SK,Home_SK,Date,Time));
    output;
 end;
 /* Reverse home/away for second half of the season */
 D + 7*&nWeeksSeason/2;
 Home_SK = _homeaway(3-Home);
 Away_SK = _homeaway(Home);
 do Date = D to D+2;
    Year = Year(Date);
    Month = Month(Date);
    DayOfWeek = weekday(Date);
    Game_SK = md5(catx(":",League_SK,Away_SK,Home_SK,Date,Time));
    output;
 end;
run;
/* "Chapter 5 GeneratePitchDistribution.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data bizarro.pitch_distribution;
 Pitch_Distribution_SK = _n_;
 input Result $16. AB_Done Is_An_AB Is_An_Out Is_A_Hit Is_An_OnBase Bases Runners_Advance_Factor From To;
 label Pitch_Distribution_SK = "Pitch Distribution Surrogate Key"
       Result = "Result of the Pitch"
       AB_Done = "Final Pitch of the AB"
       Is_An_AB = "Counts as an AB"
       Is_An_Out = "Is an Out"
       Is_A_Hit = "Is a Hit"
       Is_An_OnBase = "Counts as an On Base"
       Bases = "Number of Bases for the Hit"
       Runners_Advance_Factor = "Proabability of an Extra Base"
       From = "Lower Range of Distribution"
       to = "Upper Range of Distribution"
 ;
 datalines;
Ball             0 . . . . . .    1  33
Called Strike    0 . . . . . .   34  48
Double           1 1 0 1 1 2 .7  49  51
Error            1 1 0 0 0 1 .4  52  52
Foul             0 . . . . . .   53  68
Hit By Pitch     1 0 0 0 1 1 0   69  69
Home Run         1 1 0 1 1 4 0   70  71
Out              1 1 1 0 0 0 0   72  83
Single           1 1 0 1 1 1 .5  84  88
Swinging Strike  0 . . . . . .   89  99
Triple           1 1 0 1 1 3 0  100 100
run;
 
data bizarro.hit_distance;
 Hit_Distance_SK = _n_;
 input Pitch_Distribution_FK MinDistance MaxDistance;
 label Hit_Distance_SK = "Hit Distance Surrogate Key"
       Pitch_Distribution_FK = "Pitch Distribution Foreign Key"
       MinDistance = "Hit Distance Minimum"
       MaxDistance = "Hit Distance Maximum"
 ;
 datalines;
 3 200 300
 4  50 300
 7 390 480
 8   3 385
 9  10 100
11 310 390
run;%generateLineUps(from=&seasonStartDate,nWeeks=&nWeeksSeason)
%generatePitchAndPAData(from=&seasonStartDate,nWeeks=&nWeeksSeason)
/* "Chapter 7 Create Star Schema DW.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc datasets lib = dw nolist;
 options obs = 0;
 copy in=bizarro out=dw;
 select AtBats
        Pitches
        Runs
        Games;
 copy in=template out=dw;
 select Players_Positions_Played Players;
run;
 options obs = max;
 copy in=bizarro out=dw;
 select Leagues
        Teams;
quit;

/* The following step added post-publication to address the issue with
   an earlier rename of League to League_SK.
*/
proc sql;
 alter table dw.teams
   drop league;
quit;
/* "Chapter 7 SCD 0.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD0")
                    ,"bizarro.Players_SCD0"
                    ,"template.Players_SCD0"
                    )
                ,ordered:"A");
    scd.defineKey("Player_ID");
    scd.defineData("Team_SK","Player_ID","First_Name"
                  ,"Last_Name","Position_Code");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.AtBats(rename=(Batter_ID=Player_ID))
     end=lr;
 RC = scd.add();
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD0");
 stop;
 set template.Players_SCD0;
run;
 
data tableLookup;
 /* sample lookup code */
 if 0 then set bizarro.Players_SCD0;
 dcl hash scd(dataset:"bizarro.Players_SCD0");
 scd.defineKey("Player_ID");
 scd.defineData("Team_SK","Player_ID","First_Name"
               ,"Last_Name","Position_Code");
 scd.defineDone();
 
 /* first a key not yet in the table */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 00001;
 RC = scd.find();
 output;
 
 /* now a key already in the table */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 10103;
 RC = scd.find();
 output;
 stop;
run;/* "Chapter 7 SCD 1.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD1")
                    ,"bizarro.Players_SCD1"
                    ,"template.Players_SCD1"
                    )
                ,ordered:"A");
    scd.defineKey("Player_ID");
    scd.defineData("Team_SK","Player_ID","First_Name"
                  ,"Last_Name","Position_Code");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.atbats(rename=(Batter_ID=Player_ID))
     end=lr;
 rc = scd.replace();
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD1");
 stop;
 set template.players_scd1;
run;
 
data tableLookUp;
 /* sample lookup code */
 if 0 then set bizarro.players_SCD1;
 dcl hash scd(dataset:"bizarro.players_SCD1");
 scd.defineKey("Player_ID");
 scd.defineData("Team_SK","Player_ID","First_Name"
               ,"Last_Name","Position_Code");
 scd.defineDone();
 
 /* first a key with no data items */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 00001;
 RC = scd.find();
 output;
 /* now a key with a row of data items */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 10103;
 RC = scd.find();
 output;
 stop;
run;/* "Chapter 7 SCD 2.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD2;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD2")
                    ,"bizarro.Players_SCD2"
                    ,"template.Players_SCD2"
                    )
                ,ordered:"A",multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Team_SK"
                  ,"First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws"
                  ,"Start_Date","End_Date");
    scd.defineDone();
 end;  /* define the hash table */
 
 set bizarro.atbats
               (rename = (Batter_ID = Player_ID
                          Team_SK = _Team_SK
                          First_Name = _First_Name
                          Last_Name = _Last_Name
                          Position_Code = _Position_Code
                          Bats = _Bats
                          Throws = _Throws)
                ) end=lr;
 
 
 if scd.check() ne 0 then
 do;  /* need to add the player */
    scd.add(key: Player_ID
           ,data: Player_ID
           ,data: _Team_SK
           ,data: _First_Name
           ,data: _Last_Name
           ,data: _Position_Code
           ,data: _Bats
           ,data: _Throws
           ,data: Date
           ,data: &SCD_End_Date
           );
 end; /* need to add the player */
 else
 do;  /* check to see if there are changes */
 
    RC = scd.find();
    do while(RC = 0);
       if (Start_Date le Date le End_Date) then leave;
       RC = scd.find_next();
    end;
 
    if catx(":", Team_SK, First_Name, Last_Name
               , Position_Code, Bats, Throws) ne
       catx(":",_Team_SK,_First_Name,_Last_Name
               ,_Position_Code,_Bats,_Throws) then
    do;  /* date out prior record and add new one */;
       if RC = 0 then scd.replaceDup(data: Player_ID
                                    ,data: Team_SK
                                    ,data: First_Name
                                    ,data: Last_Name
                                    ,data: Position_Code
                                    ,data: Bats
                                    ,data: Throws
                                    ,data: Start_Date
                                    ,data: Date-1
                                    );
       scd.add(key: Player_ID
              ,data: Player_ID
              ,data: _Team_SK
              ,data: _First_Name
              ,data: _Last_Name
              ,data: _Position_Code
              ,data: _Bats
              ,data: _Throws
              ,data: Date
              ,data: &SCD_End_Date
              );
    end; /* date out prior record and add new one */;
 end;  /* check to see if there are changes */
 if lr;
 scd.output(dataset:"bizarro.Players_SCD2");
 stop;
run;
 
data tableLookup;
 /* Sample Lookup */
 if 0 then set bizarro.Players_SCD2;
 if _n_ = 1 then
 do;
    dcl hash scd(dataset:"bizarro.Players_SCD2"
                ,multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Team_SK","Player_ID","First_Name"
                  ,"Last_Name","Position_Code","Bats"
                  ,"Throws","Start_Date","End_Date");
    scd.defineDone();
 end;
 infile datalines;
 attrib Date format = yymmdd10. informat = yymmdd10.;
 input Player_ID Date;
 RC = scd.find();
 do while(RC = 0);
    if (Start_Date le Date le End_Date) then leave;
    RC = scd.find_next();
 end;
 if RC ne 0 then call missing(Team_SK,First_Name
                             ,Last_Name,Position_Code
                             ,Bats,Throws
                             ,Start_Date,End_Date);
datalines;
10103 2017/03/23
10103 2017/07/26
99999 2017/04/15
10782 2017/03/22
10782 2017/03/21
run;/* "Chapter 7 SCD 3 w Facts.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD3_Facts;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
           ifc(exist("bizarro.Players_SCD3_Facts")
              ,"bizarro.Players_SCD3_Facts"
              ,"template.Players_SCD3_Facts"
              )
                ,ordered:"A");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Team_SK"
                  ,"First_Name","Last_Name"
                  ,"First","Second","Short","Third"
                  ,"Left","Center","Right","Catcher"
                  ,"Pitcher","Pinch_Hitter");
    scd.defineDone();
    dcl hash uniqueGames();
    uniqueGames.defineKey("Game_SK"
                         ,"Player_ID"
                         ,"Position_Code");
    uniqueGames.defineDone();
 end; /* define the hash table */
 set bizarro.AtBats(rename = (Batter_ID = Player_ID))
     end=lr;
 if scd.find() ne 0 then
    call missing(First,Second,Short,Third
                ,Left,Center,Right,Catcher
                ,Pitcher,Pinch_Hitter);
 select(Position_Code);
    when("1B") First        + (uniqueGames.add() = 0);
    when("2B") Second       + (uniqueGames.add() = 0);
    when("SS") Short        + (uniqueGames.add() = 0);
    when("3B") Third        + (uniqueGames.add() = 0);
    when("LF") Left         + (uniqueGames.add() = 0);
    when("CF") Center       + (uniqueGames.add() = 0);
    when("RF") Right        + (uniqueGames.add() = 0);
    when("C" ) Catcher      + (uniqueGames.add() = 0);
    when("SP") Pitcher      + (uniqueGames.add() = 0);
    when("RP") Pitcher      + (uniqueGames.add() = 0);
    when("PH") Pinch_Hitter + (uniqueGames.add() = 0);
    otherwise;
 end;
 scd.replace();
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD3_Facts");
run;/* "Chapter 7 SCD 3.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD3;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD3")
                    ,"bizarro.Players_SCD3"
                    ,"template.Players_SCD3"
                    )
                ,ordered:"A",multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Debut_Team_SK","Team_SK"
                  ,"First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.atbats(rename=(Batter_ID = Player_ID))
     end=lr;
 _Team_SK = Team_SK;
 if scd.find() then scd.add(Key:Player_ID
                           ,Data:Player_ID
                           ,Data:Team_SK
                           ,Data:Team_SK
                           ,Data:First_Name
                           ,Data:Last_Name
                           ,Data:Position_Code
                           ,Data:Bats
                           ,Data:Throws
                           );
 else scd.replace(Key:Player_ID
                 ,Data:Player_ID
                 ,Data:Debut_Team_SK
                 ,Data:_Team_SK
                 ,Data:First_Name
                 ,Data:Last_Name
                 ,Data:Position_Code
                 ,Data:Bats
                 ,Data:Throws
                 );
 if lr;
 scd.output(dataset:"bizarro.Players_SCD3");
run;/* "Chapter 7 SCD 6.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD6;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD6")
                    ,"bizarro.Players_SCD6"
                    ,"template.Players_SCD6"
                    )
                ,ordered:"A",multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Active","SubKey"
                  ,"Team_SK","First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws"
                  ,"Start_Date","End_Date");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.atbats
               (rename = (Batter_ID = Player_ID
                          Team_SK = _Team_SK
                          First_Name = _First_Name
                          Last_Name = _Last_Name
                          Position_Code = _Position_Code
                          Bats = _Bats
                          Throws = _Throws)
               ) end=lr;
 if scd.check(Key:Player_ID) ne 0 then
 do;  /* player is new */
    scd.add(key: Player_ID
           ,data: Player_ID
           ,data: 1
           ,data: 1
           ,data: _Team_SK
           ,data: _First_Name
           ,data: _Last_Name
           ,data: _Position_Code
           ,data: _Bats
           ,data: _Throws
           ,data: Date
           ,data: &SCD_End_Date
           );
 end; /* player is new */
 else
 do;  /* check to see if there are changes */
 
    RC = scd.find();
    do while(RC = 0);
       if (Start_Date le Date le End_Date) then leave;
       RC = scd.find_next();
    end;
    if RC ne 0 then
       call missing(Team_SK,First_Name,Last_Name
                   ,Position_Code,Bats,Throws);
 
    if catx(":", Team_SK, First_Name, Last_Name
               , Position_Code, Bats, Throws) ne
       catx(":",_Team_SK,_First_Name,_Last_Name
               ,_Position_Code,_Bats,_Throws) then
    do;  /* date out prior record and add new one */;
 
       if RC = 0 then /* date out active record */
          scd.replaceDup(data: Player_ID
                        ,data: 0
                        ,data: SubKey
                        ,data: Team_SK
                        ,data: First_Name
                        ,data: Last_Name
                        ,data: Position_Code
                        ,data: Bats
                        ,data: Throws
                        ,data: Start_Date
                        ,data: Date - 1
                        );
 
       /* add row with the next autonumber value */
       _SubKey = 0;
       RC = scd.find();
       do while(RC = 0);
          RC = scd.find_next();
          _SubKey = max(_SubKey,SubKey);
       end;
       scd.add(key: Player_ID
              ,data: Player_ID
              ,data: 1
              ,data: _SubKey + 1
              ,data: _Team_SK
              ,data: _First_Name
              ,data: _Last_Name
              ,data: _Position_Code
              ,data: _Bats
              ,data: _Throws
              ,data: Date
              ,data: &SCD_End_Date
              );
    end; /* date out prior record and add new one */;
 end;  /* check to see if there are changes */
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD6"
     || "(index=(SCD6=(Player_ID Active SubKey)))");
run;
 
data tableLookup;
 /* Sample Lookup */
 retain Player_ID;
 if 0 then set bizarro.Players_SCD6(drop=Subkey);
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:"bizarro.Players_SCD6"
                ,multidata:"Y",ordered:"D");
    scd.defineKey("Player_ID","Active");
    scd.defineData("Team_SK","Player_ID","Active"
                  ,"First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws"
                  ,"Start_Date","End_Date");
    scd.defineDone();
 end; /* define the hash table */
 infile datalines;
 attrib Date format = yymmdd10. informat = yymmdd10.;
 input Player_ID Date;
 RC = scd.find(Key:Player_ID,Key:1);
 if RC = 0 and (Start_Date le Date le End_Date)
 then;
 else
 do;  /* search the inactive rows */
    RC = scd.find(Key:Player_ID,Key:0);
    do while(RC = 0);
       if (Start_Date le Date le End_Date) then leave;
       RC = scd.find_next();
    end;
 end; /* search the inactive rows */
 if RC ne 0 then
            call missing(Team_SK,Active,First_Name
                        ,Last_Name,Position_Code,Bats
                        ,Throws,Start_Date,End_Date);
datalines;
10103 2017/10/15
10103 2017/03/23
99999 2017/03/15
10782 2017/03/22
10782 2017/03/21
run;/* "Chapter 7 Update Star Schema DW.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 %createHash(hashTable=AtBats)
 %createHash(hashTable=Pitches)
 %createHash(hashTable=Runs)
 %createHash(hashTable=Games)
 %createHash(hashTable=Players_Positions_Played)
 %createHash(hashTable=Players)
 
 dcl hash uniqueGames();
 uniqueGames.defineKey("Game_SK"
                      ,"Player_ID"
                      ,"Position_Code");
 uniqueGames.defineDone();
 
 lr = 0;
 do until(lr);
    set bizarro.AtBats(rename = (Team_SK = _Team_SK
                                 First_Name = _First_Name
                                 Last_Name = _Last_Name
                                 Bats = _Bats
                                 Throws = _Throws)
                                ) end=lr;
    if game_sk ne lag(game_sk) and _AtBats.check() = 0
       then _AtBats.remove();
    _AtBats.add();
    link Games_SCD;
    Player_ID = Batter_ID;
    link Positions_Played_SCD;
    link Players_SCD;
 end;
 _AtBats.output(dataset:"dw.AtBats");
 
 lr = 0;
 do until(lr);
    set bizarro.Pitches end=lr;
    if game_sk ne lag(game_sk) and _Pitches.check() = 0
       then _Pitches.remove();
    _Pitches.add();
    Player_ID = Pitcher_ID;
    _Team_SK = Team_SK;
    _First_Name = Pitcher_First_Name;
    _Last_Name = Pitcher_Last_Name;
    _Bats = Pitcher_Bats;
    _Throws = Pitcher_Throws;
    link Players_SCD;
    Position_Code = Pitcher_Type;
    link Positions_Played_SCD;
 end;
 _Pitches.output(dataset:"dw.Pitches");
 
 lr = 0;
 do until(lr);
    set bizarro.Runs end=lr;
    if game_sk ne lag(game_sk) and _Runs.check() = 0
       then _Runs.remove();
    _Runs.add();
 end;
 _Runs.output(dataset:"dw.Runs");
 
 /* output the updated dimension tables */
 _games.output(dataset:"dw.Games");
 _Players_Positions_Played.output
                          (dataset:"dw.Players_Positions_Played");
 _Players.output(dataset:"dw.Players");
 stop;
 
 Games_SCD:
  Year = Year(Date);
  Month = Month(Date);
  DayOfWeek = weekday(Date);
  _games.replace();
 return;
 
 Positions_Played_SCD:
  if _Players_Positions_Played.find() ne 0
     then call missing(First,Second,Short,Third,Left
                      ,Center,Right,Catcher,Pitcher);
  select(Position_Code);
     when("1B") First        + (uniqueGames.add() = 0);
     when("2B") Second       + (uniqueGames.add() = 0);
     when("SS") Short        + (uniqueGames.add() = 0);
     when("3B") Third        + (uniqueGames.add() = 0);
     when("LF") Left         + (uniqueGames.add() = 0);
     when("CF") Center       + (uniqueGames.add() = 0);
     when("RF") Right        + (uniqueGames.add() = 0);
     when("C" ) Catcher      + (uniqueGames.add() = 0);
     when("SP") Pitcher      + (uniqueGames.add() = 0);
     when("RP") Pitcher      + (uniqueGames.add() = 0);
     when("PH") Pinch_Hitter + (uniqueGames.add() = 0);
     otherwise;
  end;
  _Players_Positions_Played.replace();
 return;
 
 Players_SCD:
  if _Players.check() ne 0 then
  do;  /* need to add the player */
     _Players.add(key: Player_ID
                 ,data: Player_ID
                 ,data: _Team_SK
                 ,data: _First_Name
                 ,data: _Last_Name
                 ,data: _Bats
                 ,data: _Throws
                 ,data: Date
                 ,data: &SCD_End_Date
                 );
  end; /* need to add the player */
  else
  do;  /* check to see if there are changes */
 
     RC = _Players.find();
     do while(RC = 0);
        if (Start_Date le Date le End_Date) then leave;
        RC = _Players.find_next();
     end;
 
     if catx(":", Team_SK, First_Name, Last_Name
                , Bats, Throws) ne
        catx(":",_Team_SK,_First_Name,_Last_Name
                ,_Bats,_Throws) then
     do;  /* date out prior record and add new one */
        if RC = 0 then
                  _Players.replaceDup(data: Player_ID
                                     ,data: Team_SK
                                     ,data: First_Name
                                     ,data: Last_Name
                                     ,data: Bats
                                     ,data: Throws
                                     ,data: Start_Date
                                     ,data: Date-1
                                     );
        _Players.add(key: Player_ID
                    ,data: Player_ID
                    ,data: _Team_SK
                    ,data: _First_Name
                    ,data: _Last_Name
                    ,data: _Bats
                    ,data: _Throws
                    ,data: Date
                    ,data: &SCD_End_Date
                    );
     end; /* date out prior record and add new one */;
  end;  /* check to see if there are changes */
 return;
run;
/* ///@endcond */
