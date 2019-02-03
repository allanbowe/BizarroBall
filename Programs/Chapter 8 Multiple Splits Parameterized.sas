/* "Chapter 8 Multiple Splits Parameterized.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%macro createHash
       (hashTable = hashTable
       ,parmfile = template.Chapter8ParmFile
       );
 
 lr = 0;
 dcl hash &hashTable(ORDERED:"A");
 do while(lr=0);
    set &parmfile end=lr;
    where upcase(hashTable) = "%upcase(&hashTable)";
    if Is_A_key then &hashTable..DefineKey(Column);
    &hashTable..DefineData(Column);
 end;
 &hashTable..DefineDone();
 
%mend createHash;
 
proc sql noprint;
 select distinct cats('%createHash(hashTable='
                     ,hashTable
                     ,")"
                      )
 into:createHashCalls separated by " "
 from template.Chapter8ParmFile;
 select distinct cats("h_pointer="
                     ,hashTable
                     ,";"
                     ,"link slashline"
                     )
 into:calcHash separated by ";"
 from template.Chapter8ParmFile;
 select distinct cats(hashTable
                     ,'.output(dataset:"_'
                     ,hashTable
                     ,'(drop=_:)")'
                     )
 into:outputHash separated by ";"
 from template.Chapter8ParmFile;
 /*reset print;
 select Name, Value from dictionary.macros
 where name in ("CREATEHASHCALLS" "CALCHASH"
                "OUTPUTHASH");*/
quit;
 
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
 
 &createHashCalls
 
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
    &calcHash;
 end;
 &outputHash;
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