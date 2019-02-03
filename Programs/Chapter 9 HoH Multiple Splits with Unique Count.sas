/* "Chapter 9 HoH Multiple Splits with Unique Count.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 dcl hash HoH(ordered:"A");
 HoH.defineKey("hashTable");
 HoH.defineData("hashTable","H","ITER","calcAndOutput","U");
 HoH.defineDone();
 dcl hiter HoH_Iter("HoH");
 dcl hash h();
 dcl hash u();
 dcl hiter iter;
 /* define the lookup hash object tables */
 do while(lr=0);
    set template.chapter9lookuptables
        template.chapter9splits(in = CalcAndOutput)
    end=lr;
    by hashTable;
    if first.hashTable then
    do;  /* create the hash object instance */
       if datasetTag ne ' ' then
       do;  /* create the lookup table hash object */
          h = _new_ hash(dataset:datasetTag,multidata:"Y");
          u = _new_ hash(); /* not used */
       end; /* create the lookup table hash object */
       else
       do;  /* create the two hash objects for the calculations */
          h = _new_ hash();
          u = _new_ hash();
       end; /* create the two hash objects for the calculations */
    end; /* create the hash object instance */
    if Is_A_Key then
    do;  /* define the keys for the two hash objects for the calculations */
       h.DefineKey(Column);
       u.DefineKey(Column);
       if calcAndOutput then u.DefineKey("Game_SK");
    end; /* define the keys for the two hash objects for the calculations */
    h.DefineData(Column);
    if last.hashTable then
    do;  /* close the definition and add it to our HoH hash table */
       if calcAndOutput then h.DefineData("N_Games");
       h.defineDone();
       u.defineDone();
       HoH.add();
    end; /* close the definition and add it to our HoH hash table */
 end;
 /* create non-scalar fields for the needed lookup tables */
 HoH.find(key:"GAMES");
 dcl hash games;
 games = h;
 HoH.find(key:"PLAYERS");
 dcl hash players;
 players = h;
 HoH.find(key:"TEAMS");
 dcl hash teams;
 teams = h;
 
 if 0 then set dw.players
               dw.teams
               dw.games;
 format PAs AtBats Hits comma6. BA OBP SLG OPS 5.3;
 
 lr = 0;
 do until(lr);
    set dw.AtBats(rename=(batter_id=player_id)) end = lr;
    call missing(Team_SK,Last_Name,First_Name,Team_Name,Date,Month,DayOfWeek);
    games.find();
    players_rc = players.find();
    do while(players_rc = 0);
       if (Start_Date le Date le End_Date) then leave;
       players_rc = players.find_next();
    end;
    if players_rc ne 0 then call missing(Team_SK,First_Name,Last_Name);
    teams.find();
    do while (HoH_Iter.next() = 0);
       if not calcAndOutput then continue;
       call missing(N_Games,PAs,AtBats,Hits,_Bases,_Reached_Base);
       rc = h.find();
       N_Games + (u.add() = 0);
       PAs           + 1;
       AtBats        + Is_An_AB;
       Hits          + Is_A_Hit;
       _Bases        + Bases;
       _Reached_Base + Is_An_OnBase;
       BA = divide(Hits,AtBats);
       OBP = divide(_Reached_Base,PAs);
       SLG = divide(_Bases,AtBats);
       OPS = sum(OBP,SLG);
       h.replace();
    end;
 end;
 do while (HoH_Iter.next() = 0);
    if not calcAndOutput  then continue;
    h.output(dataset:hashTable||"(drop=_:)");
 end;
 stop;
run;