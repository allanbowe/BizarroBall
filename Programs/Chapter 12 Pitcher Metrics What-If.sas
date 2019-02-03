/* "Chapter 12 Pitcher Metrics What-If.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data chapter9splits;
 set template.chapter9splits;
 by hashTable;
 output;
 if last.hashTable;
 Column = "IP";
 output;
 Column = "ERA";
 output;
 Column = "WHIP";
 output;
 Column = "_Runs";
 output;
 Column = "_Outs";
 output;
 Column = "_Walks";
 output;
 Column = "_HBP";
 output;
 Column = "WHIP_HBP";
 output;
 Column = "BASES_IP";
 output;
run;
 
data _null_;
 dcl hash HoH(ordered:"A");
 HoH.defineKey("hashTable");
 HoH.defineData("hashTable","H","calcAndOutput");
 HoH.defineDone();
 dcl hiter HoH_Iter("HoH");
 dcl hash h();
 dcl hiter iter;
 /* define the lookup hash object tables */
 do while(lr=0);
    set template.chapter9lookuptables
        chapter9splits(in=CalcAndOutput)
    end=lr;
    by hashTable;
    if first.hashTable then
    do;  /* create the hash object instance */
       if datasetTag ne ' ' then h = _new_ hash(dataset:datasetTag
                                               ,multidata:"Y");
       else h = _new_ hash(multidata:"Y");
    end; /* create the hash object instance */
    if Is_A_key then h.DefineKey(Column);
    h.DefineData(Column);
    if last.hashTable then
    do;  /* close the definition and add it to our HoH hash table */
       h.defineDone();
       HoH.add();
    end; /* close the definition and add it to our HoH hash table */
 end;
 /* create non-scalar fields for the lookup tables */
 HoH.find(key:"GAMES");
 dcl hash games;
 games = h;
 HoH.find(key:"PLAYERS");
 dcl hash players;
 players = h;
 HoH.find(key:"TEAMS");
 dcl hash teams;
 teams = h;
 dcl hash pitchers(dataset:"dw.pitches(rename=(pitcher_id = Player_ID))");
 pitchers.defineKey("game_sk","top_bot","ab_number");
 pitchers.defineData("player_id");
 pitchers.defineDone();
 
 if 0 then set dw.players
               dw.teams
               dw.games
               dw.pitches;
 format PAs AtBats Hits comma6. BA OBP SLG OPS 5.3
        IP comma6. ERA WHIP WHIP_HBP BASES_IP 6.3;
 
 lr = 0;
 do until(lr);
    set dw.AtBats end = lr;
    call missing(Team_SK,Last_Name,First_Name,Team_Name,Date,Month,DayOfWeek);
    games.find();
    pitchers.find();
    players_rc = players.find();
    do while(players_rc = 0);
       if (Start_Date le Date le End_Date) then leave;
       players_rc = players.find_next();
    end;
    if players_rc ne 0 then call missing(Team_SK,First_Name,Last_Name);
    teams.find();
 
    do while (HoH_Iter.next() = 0);
       if not calcAndOutput then continue;
       call missing(PAs,AtBats,Hits,_Bases,_Reached_Base
                   ,_Outs,_Runs,_Bases,_HBP);
       rc = h.find();
       PAs           + 1;
       AtBats        + Is_An_AB;
       Hits          + Is_A_Hit;
       _Bases        + Bases;
       _Reached_Base + Is_An_OnBase;
       _Outs         + Is_An_Out;
       _Runs         + Runs;
       _Walks        + (Result = "Walk");
       _HBP          + (Result = "Hit By Pitch");
       BA = divide(Hits,AtBats);
       OBP = divide(_Reached_Base,PAs);
       SLG = divide(_Bases,AtBats);
       OPS = sum(OBP,SLG);
       if _Outs then
       do;  /* calculate pitcher metrics suppressing missing value note */
          IP = _Outs/3;
          ERA = divide(_Runs*9,IP);
          WHIP = divide(sum(_Walks,Hits),IP);
          WHIP_HBP = divide(sum(_Walks,Hits,_HBP),IP);
          BASES_IP = divide(_Bases,IP);
       end; /* calculate pitcher metrics missing value note */
       h.replace();
    end;
 end;
 do while (HoH_Iter.next() = 0);
    if not calcAndOutput  then continue;
    h.output(dataset:hashTable||"(drop=_:)");
 end;
 stop;
run;