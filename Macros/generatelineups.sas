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
