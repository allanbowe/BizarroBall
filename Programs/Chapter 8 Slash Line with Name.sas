/* "Chapter 8 Slash Line with Name.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 dcl hash slashline(ordered:"A");
 slashline.defineKey("Last_Name","First_Name","Batter_ID");
 slashline.defineData("Batter_ID","Last_Name","First_Name","Team_SK"
                     ,"PAs","AtBats","Hits","_Bases","_Reached_Base"
                     ,"BA","OBP","SLG","OPS");
 slashline.defineDone();
 if 0 then set dw.players(rename=(Player_ID=Batter_ID));
 dcl hash players(dataset:"dw.players(rename=(Player_ID=Batter_ID))"
                 ,duplicate:"replace");
 players.defineKey("Batter_ID");
 players.defineData("Batter_ID","Team_SK","Last_Name","First_Name");
 players.defineDone();
 format BA OBP SLG OPS 5.3;
 do until(lr);
    set dw.AtBats end = lr;
    call missing(Last_Name,First_Name,Team_SK
                ,PAs,AtBats,Hits,_Bases,_Reached_Base);
    players.find();
    rc = slashline.find();
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
 end;
 slashline.output(dataset:"Batter_Slash_Line(drop=_:)");
run;