/* "Chapter 8 Slash Line with Unique Count.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 dcl hash slashline(ordered:"A");
 slashline.defineKey("League","Team_Name","Last_Name","First_Name","Batter_ID");
 slashline.defineData("League","Team_Name","Batter_ID","Last_Name","First_Name"
                     ,"Games","PAs","AtBats","Hits","_Bases","_Reached_Base"
                     ,"BA","OBP","SLG","OPS");
 slashline.defineDone();
 if 0 then set dw.players(rename=(Player_ID=Batter_ID))
               dw.teams
               dw.leagues;
 dcl hash players(dataset:"dw.players (rename=(Player_ID=Batter_ID))"
                 ,duplicate:"replace");
 players.defineKey("Batter_ID");
 players.defineData("Batter_ID","Team_SK","Last_Name","First_Name");
 players.defineDone();
 dcl hash teams(dataset:"dw.teams");
 teams.defineKey("Team_SK");
 teams.defineData("League_SK","Team_Name");
 teams.defineDone();
 dcl hash leagues(dataset:"dw.leagues");
 leagues.defineKey("League_SK");
 leagues.defineData("League");
 leagues.defineDone();
 dcl hash u();
 u.defineKey("League","Team_Name","Batter_ID","Game_SK");
 u.defineDone();
 format BA OBP SLG OPS 5.3;
 do until(lr);
    set dw.AtBats end = lr;
    call missing(Last_Name,First_Name,Team_SK,Games
                ,PAs,AtBats,Hits,_Bases,_Reached_Base);
    players.find();
    teams.find();
    leagues.find();
    link slashline;
    call missing(Batter_ID,Last_Name,First_Name,Games);
    link slashline;
    call missing(Team_Name,Games);
    link slashline;
 end;
 slashline.output(dataset:"Batter_Slash_Line(drop=_:)");
 return;
 slashline:
    rc = slashline.find();
    Games + (u.add() = 0);
    PAs           + 1;
    AtBats        + Is_An_AB;
    Hits          + Is_A_Hit;
    _Bases        + Bases;
    _Reached_Base + Is_An_OnBase;
    BA = divide(Hits,AtBats);
    OBP = divide(_Reached_Base,PAs);
    SLG = divide(_Bases,AtBats);
    OPS = sum(OBP,SLG);
    slashline.replace();
 return;
run;