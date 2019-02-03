/* "Chapter 9 HoH Multiple Splits Batter and Pitcher.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data chapter9splits;
 set template.chapter9splits
     template.chapter9splits(in=asPitcher);
 by hashTable;
 if asPitcher
    then hashTable = catx("_",hashTable,"PITCHER");
    else hashTable = catx("_",hashTable,"BATTER");
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
run;
 
proc sort data = chapter9splits out = chapter9splits equals;
 by hashTable;
run;
 
proc sql;
 create table pitchers as
 select distinct game_sk, top_bot, ab_number, pitcher_id
 from dw.pitches;
quit;
 
data _null_;
 dcl hash HoH(ordered:"A");
 HoH.defineKey ("hashTable");
 HoH.defineData ("hashTable","H","ITER","CalcAndOutput");
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
 dcl hash pitchers(dataset:"Pitchers");
 pitchers.defineKey("game_sk","top_bot","ab_number");
 pitchers.defineData("pitcher_id");
 pitchers.defineDone();
 
 if 0 then set dw.players
               dw.teams
               dw.games
               dw.pitches;
 format PAs AtBats Hits comma6.
        BA OBP SLG OPS 5.3
        IP comma6. ERA WHIP 6.3;
 
 lr = 0;
 do until(lr);
    set dw.AtBats end = lr;
    call missing(Team_SK,Last_Name,First_Name,Team_Name,Date,Month,DayOfWeek);
    games.find();
    pitchers.find();
    do while (HoH_Iter.next() = 0);
       if not calcAndOutput then continue;
       call missing(PAs,AtBats,Hits,_Bases,_Reached_Base,_Outs,_Runs);
       if upcase(scan(hashTable,-1,"_")) = "BATTER" then player_id = batter_id;
       else player_id = pitcher_id;
       players_rc = players.find();
       do while(players_rc = 0);
          if (Start_Date le Date le End_Date) then leave;
          players_rc = players.find_next();
       end;
       if players_rc ne 0 then call missing(Team_SK,First_Name,Last_Name);
       teams.find();
       rc = h.find();
       PAs           + 1;
       AtBats        + Is_An_AB;
       Hits          + Is_A_Hit;
       _Bases        + Bases;
       _Reached_Base + Is_An_OnBase;
       _Outs         + Is_An_Out;
       _Runs         + Runs;
       _Walks        + (Result = "Walk");
       BA = divide(Hits,AtBats);
       OBP = divide(_Reached_Base,PAs);
       SLG = divide(_Bases,AtBats);
       OPS = sum(OBP,SLG);
       if _Outs then
       do;  /* calculate pitcher metrics suppressing missing value note */
          IP = _Outs/3;
          ERA = divide(_Runs*9,IP);
          WHIP = divide(sum(_Walks,Hits),IP);
       end; /* calculate pitcher metrics suppressing missing value note */
       h.replace();
    end;
 end;
 do while (HoH_Iter.next() = 0);
    if not calcAndOutput  then continue;
    h.output(dataset:hashTable||"(drop=_:)");
 end;
 stop;
run;