/* "Chapter 13 Long At Bats with Initial 0-2 Count.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let Number_of_Pitches = 10;
 
data _null_;
 if 0 then set dw.pitches(keep = Pitcher_ID)
               dw.players
               dw.games
               dw.teams
               dw.runs
 ;
 
 /* define the lookup hash object lookup tables */
 dcl hash HoH(ordered:"A");
 HoH.defineKey ("hashTable");
 HoH.defineData ("hashTable","H");
 HoH.defineDone();
 dcl hash h();
 do while(lr=0);
    set template.chapter9lookuptables end=lr;
    by hashTable;
    if first.hashTable then h = _new_ hash(dataset:datasetTag,multidata:"Y");
    if Is_A_Key then h.DefineKey(Column);
    h.DefineData(Column);
    if last.hashTable then
    do;  /* close the definition and add it to our HoH hash table */
       h.defineDone();
       rc=HoH.add();
    end; /* close the definition and add it to our HoH hash table */
 end;
 
 HoH.find(key:"GAMES");
 dcl hash games;
 games = h;
 HoH.find(key:"PLAYERS");
 dcl hash players;
 players = h;
 HoH.find(key:"TEAMS");
 dcl hash teams;
 teams = h;
 
 dcl hash Count_0_2(dataset:"DW.Pitches(where=(Strikes = 2 and Balls = 0))");
 Count_0_2.defineKey("game_sk","top_bot","ab_number");
 Count_0_2.defineData("Pitcher_ID");
 Count_0_2.defineDone();
 
 dcl hash results(multidata:"Y",ordered:"A");
 results.defineKey("Date");
 results.defineData("Date","Team_AtBat","Team_InField","AB_Number","Result"
                   ,"Number_of_Pitches","Runs","Batter","Pitcher","Runner");
 results.defineDone();
 
 dcl hash runners(dataset:"DW.Runs",multidata:"Y");
 runners.defineKey("Game_SK","Top_Bot","AB_Number");
 runners.defineData("Runner_ID");
 runners.defineDone();
 
 dcl hash distribution(ORDERED:"A");
 distribution.defineKey("Result");
 distribution.defineData("Result","Count");
 distribution.defineDone();
 
 lr = 0;
 do until(lr);
    set dw.atbats end = lr;
    where Number_of_Pitches >= &Number_of_Pitches;
    if Count_0_2.find() > 0 then continue;
    if distribution.find() gt 0 then Count = 0;
    Count = Count + 1;
    distribution.replace();
    games.find();
    players_rc = players.find(Key:Batter_ID);
    link players;
    Batter = catx(', ',Last_Name,First_Name);
    Team_AtBat = Team_Name;
    players_rc = players.find(Key:Pitcher_ID);
    link players;
    Pitcher = catx(', ',Last_Name,First_Name);
    Team_InField = Team_Name;
    if runs then
    do;  /* if runs scored - get runner data */
       rc = runners.find();
       do while(rc=0);
          players_rc = players.find(Key:Runner_ID);
          link players;
          Runner = catx(', ',Last_Name,First_Name);
          results.add();
          rc = runners.find_next();
       end;
    end; /* if runs scored - get runner data */
    else
    do;  /* no runs scored */
       Runner = ' ';
       results.add();
    end; /* no runs scored */
 end;
 results.output(dataset:"Runs_Scored(where=(Runs))");
 results.output(dataset:"No_Runs_Scored(where=(not Runs))");
 distribution.output(dataset:"Distribution");
 stop;
 return;
 players:
    do while(players_rc = 0);
       if (Start_Date le Date le End_Date) then leave;
       players_rc = players.find_next();
    end;
    if players_rc ne 0 then call missing(Team_SK,First_Name,Last_Name);
    teams.find();
 return;
 stop;
run;
 
ods rtf bodytitle file = "&root\Results\Chapter 13 Long AtBats with Initial 0-2 Count.rtf";
options nobyline nodate nonumber nocenter nolabel;
proc print data = distribution noobs;
 sum count;
 title "Output 13. Results Distribution";
run;
proc report data = runs_scored split="_"
   style(report)=[font_size=8pt]
   style(header)=[font_size=8pt]
   style(column)=[font_size=8pt];
 columns Date Batter Team_AtBat Runner Runs Pitcher Team_InField
         AB_Number Number_of_Pitches Result;
 define Date / display id;
 define Batter / group order=data;
 define Team_AtBat / display;
 define Pitcher / display;
 define Team_InField / display;
 define AB_Number / display;
 define Runs / group;
 title "Output 13. Runs Scored";
 footnote;
run;
proc report data = no_runs_scored split="_"
   style(report)=[font_size=8pt]
   style(header)=[font_size=8pt]
   style(column)=[font_size=8pt];
 columns Date Batter Team_AtBat Pitcher Team_InField AB_Number Number_of_Pitches Result;
 define Date / display id;
 define Batter / display;
 define Team_AtBat / display;
 define Pitcher / display;
 define Team_InField / display;
 define AB_Number / display;
 title "Output 13. No Runs Scored";
 footnote;
run;
ods _all_ close;
options label;
