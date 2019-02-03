/* "Chapter 8 Multiple Splits.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 /* define the lookup hash object tables */
 dcl hash players(dataset:"dw.players(rename=(Player_ID=Batter_ID))"
                 ,multidata:"Y");
 players.defineKey("Batter_ID");
 players.defineData("Batter_ID","Team_SK","Last_Name","First_Name"
                   ,"Start_Date","End_Date");
 players.defineDone();
 dcl hash teams(dataset:"dw.teams");
 teams.defineKey("Team_SK");
 teams.defineData("Team_Name");
 teams.defineDone();
 dcl hash games(dataset:"dw.games");
 games.defineKey("Game_SK");
 games.defineData("Date","Month","DayOfWeek");
 games.defineDone();
 /* define the result hash object tables */
 dcl hash h_pointer;
 dcl hash byPlayer(ordered:"A");
 byPlayer.defineKey("Last_Name","First_Name","Batter_ID");
 byPlayer.defineData("Last_Name","First_Name","Batter_ID","PAs","AtBats","Hits"
                    ,"_Bases","_Reached_Base","BA","OBP","SLG","OPS");
 byPlayer.defineDone();
 
 dcl hash byTeam(ordered:"A");
 byTeam.defineKey("Team_SK","Team_Name");
 byTeam.defineData("Team_Name","Team_SK","PAs","AtBats","Hits"
                  ,"_Bases","_Reached_Base","BA","OBP","SLG","OPS");
 byTeam.defineDone();
 
 dcl hash byMonth(ordered:"A");
 byMonth.defineKey("Month");
 byMonth.defineData("Month","PAs","AtBats","Hits"
                   ,"_Bases","_Reached_Base","BA","OBP","SLG","OPS");
 byMonth.defineDone();
 
 dcl hash byDayOfWeek(ordered:"A");
 byDayOfWeek.defineKey("DayOfWeek");
 byDayOfWeek.defineData("DayOfWeek","PAs","AtBats","Hits"
                       ,"_Bases","_Reached_Base","BA","OBP","SLG","OPS");
 byDayOfWeek.defineDone();
 
 dcl hash byPlayerMonth(ordered:"A");
 byPlayerMonth.defineKey("Last_Name","First_Name","Batter_ID","Month");
 byPlayerMonth.defineData("Last_Name","First_Name","Batter_ID","Month"
                         ,"PAs","AtBats","Hits","_Bases","_Reached_Base"
                         ,"BA","OBP","SLG","OPS");
 byPlayerMonth.defineDone();
 
 if 0 then set dw.players(rename=(Player_ID=Batter_ID))
               dw.teams
               dw.games;
 format PAs AtBats Hits comma6. BA OBP SLG OPS 5.3;
 
 lr = 0;
 do until(lr);
    set dw.AtBats end = lr;
    call missing(Team_SK,Last_Name,First_Name,Team_Name,Date,Month,DayOfWeek);
    games.find();
    players_rc = players.find();
    do while(players_rc = 0);
       if (Start_Date le Date le End_Date) then leave;
       players_rc = players.find_next();
    end;
    if players_rc ne 0
       then call missing(Team_SK,First_Name,Last_Name);
    teams.find();
    h_pointer = byPlayer;
    link slashline;
    h_pointer = byTeam;
    link slashline;
    h_pointer = byMonth;
    link slashline;
    h_pointer = byDayOfWeek;
    link slashline;
    h_pointer = byPlayerMonth;
    link slashline;
 end;
 byPlayer.output(dataset:"byPlayer(drop=_:)");
 byTeam.output(dataset:"byTeam(drop=_:)");
 byMonth.output(dataset:"byMonth(drop=_:)");
 byDayOfWeek.output(dataset:"byDayOfWeek(drop=_:)");
 byPlayerMonth.output(dataset:"byPlayerMonth(drop=_:)");
 stop;
 slashline:
    call missing(PAs,AtBats,Hits,_Bases,_Reached_Base);
    rc = h_pointer.find();
    PAs           + 1;
    AtBats        + Is_An_AB;
    Hits          + Is_A_Hit;
    _Bases        + Bases;
    _Reached_Base + Is_An_OnBase;
    BA = divide(Hits,AtBats);
    OBP = divide(_Reached_Base,PAs);
    SLG = divide(_Bases,AtBats);
    OPS = sum(OBP,SLG);
    h_pointer.replace();
 return;
run;

