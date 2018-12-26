/* Create data source (change root to a permanent location) */
%let root = %sysfunc(pathname(work));
options dlcreatedir;
libname bizarro "&root/Data";

/* Parameters for creating the data */
%let nTeamsPerLeague = 16;
%let seasonStartDate = 01MAR2017;
%let seasonEndDate = 31MAR2017;
%let nPlayersPerTeam = 50;
%let nBattersPerGame = 14;
%let springTrainingFactor = 2;

/* Random Number Seeds */
%let seed1 = 54321;
%let seed2 = 98765;
%let seed3 = 76543;
%let seed4 = 11;
%let seed5 = 9887;
%let seed6 = 9973;
%let seed7 = 101;

/* now include macros & datalines */
%macro generateLineUps
       (from =
       ,to =
       );

 %if %length(&to) = 0 %then %let to = &from;

 %do date = %sysfunc(inputn(&from,date9.)) %to %sysfunc(inputn(&to,date9.));

    data players;
     set bizarro.players;
     randomize = uniform(&date*&seed5+&seed6);  /* randomize the order for each date */
    run;

    data _null_;;

     if 0 then set players bizarro.schedule; /* define vars to PDV */
     length Batting_Order Pitching_Order 3;

     declare hash BatterLineUp(multidata:'y');
     rc = BatterLineUp.defineKey('Game_SK','Team_SK');
     rc = BatterLineUp.defineData('Game_SK','Team_SK','Batting_Order','Player_ID');
     rc = BatterLineUp.defineDone();

     declare hash pitcherOrder(multidata:'y');
     rc = pitcherOrder.defineKey('Game_SK','Team_SK');
     rc = pitcherOrder.defineData('Game_SK','Team_SK','Pitching_Order','Player_ID');
     rc = pitcherOrder.defineDone();

     declare hash temp(dataset:'players(where=(position_code not in ("SP" "RP")))',ordered:'a',multidata:'y');
     rc = temp.defineKey('Randomize','Team_SK');
     rc = temp.defineData('Team_SK','Player_ID');
     rc = temp.defineDone();
     declare hiter temp_iter('temp');
    
     declare hash batters(multidata:'y');
     rc = batters.defineKey('Team_SK');
     rc = batters.defineData('Team_SK','Player_ID');
     rc = batters.defineDone();
     temp_rc = temp_iter.first();
     do until(temp_rc ne 0);
        rc = batters.add();
        temp_rc = temp_iter.next();
     end;
     rc = batters.output(dataset:'b');
    
     rc = temp.delete();  /* talk to Paul why can't be reused */

     declare hash temp2(dataset:'players(where=(position_code in ("SP" "RP")))',ordered:'a',multidata:'y');
     rc = temp2.defineKey('Randomize','Team_SK');
     rc = temp2.defineData('Team_SK','Player_ID');
     rc = temp2.defineDone();
     declare hiter temp2_iter('temp2');
    
     declare hash pitchers(multidata:'y');
     rc = pitchers.defineKey('Team_SK');
     rc = pitchers.defineData('Team_SK','Player_ID');
     rc = pitchers.defineDone();
     temp_rc = temp2_iter.first();
     do until(temp_rc ne 0);
        rc = pitchers.add();
        temp_rc = temp2_iter.next();
     end;
     rc = pitchers.output(dataset:'p');
    
     declare hash games(ordered:'a',multidata:'y');
     rc = games.defineKey('Team_SK');
     rc = games.defineData('Game_SK','Team_SK','Time');
     rc = games.defineDone();
    
     lr = 0;
     do until(lr);
        set bizarro.schedule(where=(date=&date)) end=lr;
    	rc = games.add(key:Away_SK
                      ,data:Game_SK,data:Away_SK,data:Time
                      );
    	rc = games.add(key:Home_SK
                      ,data:Game_SK,data:Home_SK,data:Time
                      );
     end;
     rc = games.output(dataset:'t');

     lr = 0;
     do until(lr);
        set bizarro.teams end=lr;
        batters.find();
        do while (games.do_over() = 0);
           do Batting_Order = 1 to &nBattersPerGame;
              BatterLineUp.add();
              rc = batters.find_next();
           end;
        end;
     end;
     BatterLineUp.output(dataset:'Batters');

     lr = 0;
     do until(lr);
        set bizarro.teams end=lr;
        pitchers.find();
        do while (games.do_over() = 0);
           do Pitching_Order = 1 to 9;
              PitcherOrder.add();
              rc = pitchers.find_next();
           end;
        end;
     end;
     PitcherOrder.output(dataset:'Pitchers');

     stop;
    run;

    %if %sysfunc(exist(Bizarro.Batters)) %then
    %do;  /* delete existing rows for these games */
       proc sql;
        delete from Bizarro.Batters
        where Game_SK in (select distinct Game_SK from batters);
       quit;

       proc datasets lib=bizarro nolist;
        modify batters;
        index delete batters;
       run;
    %end; /* delete existing rows for these games */

    proc append base = Bizarro.Batters data = Batters;
    run;

    %if %sysfunc(exist(Bizarro.Pitchers)) %then
    %do;  /* delete existing rows for these games */
       proc sql;
        delete from Bizarro.Pitchers
        where Game_SK in (select distinct Game_SK from pitchers);
       quit;

       proc datasets lib=bizarro nolist;
        modify pitchers;
        index delete pitchers;
       run;
    %end; /* delete existing rows for these games */

    proc append base = Bizarro.Pitchers data = Pitchers;
    run;

    proc datasets lib=bizarro nolist;
     modify batters;
     index create batters=(Game_SK Team_SK);
     modify pitchers;
     index create pitchers=(Game_SK Team_SK);
    quit;
 %end;
%mend generateLineUps;
%macro generatePitchAndPAData
       (from =
       ,to =
       );

 %if %length(&to) = 0 %then %let to = &from;

 %do date = %sysfunc(inputn(&from,date9.)) %to %sysfunc(inputn(&to,date9.));

    data pitches(drop = Is_An_AB Is_An_Out Is_A_Hit Bases onFirst onSecond onThird Runs Left_on_Base
                        Team_SK Batting_Order Batter_ID Pitching_Order Runner_ID
                )
         atbats(drop = Is_A_Ball Is_A_Strike Team_SK Batting_Order Pitcher_ID Pitching_Order Runner_ID
               rename=(Pitch_Number=Number_of_Pitches))
         runs(keep=Game_SK Top_Bot AB_Number Batter_ID Runner_ID)
    ;

     if 0 then set bizarro.batters(rename=(Player_ID=Batter_ID))     /* define vars to PDV */
                   bizarro.pitchers(rename=(Player_ID=Pitcher_ID))
     ;

     drop i rc Index From To AB_Done Runners_Advance_Factor Away_SK Home_SK Date;

     retain Inning 1;
     array runners(*) onFirst onSecond onThird;
     length Runs 3;

     if _n_ = 1 then
     do;  /* define the needed hash tables */

        declare hash pitch_dist(ordered:'a');
        rc = pitch_dist.DefineKey('Index');
        rc = pitch_dist.DefineData('Index','Result','AB_Done','Is_An_Ab','Is_An_Out','Is_A_Hit','Bases','Runners_Advance_Factor');
        rc = pitch_dist.DefineDone();
        lr = 0;
        do until(lr);
           set bizarro.pitch_distribution end=lr;
           do Index = From to To;
              rc =pitch_dist.add();
           end;
        end;

        declare hash batters(ordered:'a');
        rc = batters.DefineKey('Top_Bot','Batting_Order');
        rc = batters.DefineData('Top_Bot','Batter_ID');
        rc = batters.DefineDone();

        declare hash pitchers(ordered:'a');
        rc = pitchers.DefineKey('Top_Bot','Pitching_Order');
        rc = pitchers.DefineData('Top_Bot','Pitcher_ID');
        rc = pitchers.DefineDone();

     end; /* define the needed hash tables */

     set bizarro.schedule(keep=Game_SK Away_SK Home_SK Date);
     where date=&date;
 
     /* load the batter data for this game */
     rc = batters.clear();
     team_sk = away_sk;
     Top_Bot = 'T';
     do until(_iorc_ ne 0);
        set bizarro.batters(rename=(Player_ID=Batter_ID)) key = batters;
        if _iorc_ = 0 then rc = batters.add();
     end;
     team_sk = home_sk;
     Top_Bot = 'B';
     do until(_iorc_ ne 0);
        set bizarro.batters(rename=(Player_ID=Batter_ID)) key = batters;
        if _iorc_ = 0 then rc = batters.add();
     end;
 
     /* load the pitcher data for this game */
     rc = pitchers.clear();
     team_sk = away_sk;
     Top_Bot = 'B';
     do until(_iorc_ ne 0);
        set bizarro.pitchers(rename=(Player_ID=Pitcher_ID)) key = pitchers;
        if _iorc_ = 0 then rc = pitchers.add();
     end;
     team_sk = home_sk;
     Top_Bot = 'T';
     do until(_iorc_ ne 0);
        set bizarro.pitchers(rename=(Player_ID=Pitcher_ID)) key = pitchers;
        if _iorc_ = 0 then rc = pitchers.add();
     end;

     *rc = batters.output(dataset:'b');
     *rc = pitchers.output(dataset:'p');

     _error_ = 0;  /* suppress the error message when the indexed read failed as expected */

     do Top_Bot = 'T', 'B';   /* cheating a bit here - discuss with Paul */
        AB_Number = 0;
        do Inning = 1 to 9;
           rc = pitchers.find(key:Top_Bot,Key:Inning);
           outs = 0;
              onFirst = .;
           onSecond = .;
           onThird = .;
           do until(outs=3);
              Is_An_Out = 0;
              Balls = 0;
              Strikes = 0;
              Pitch_Number = 0;
              AB_Number + 1;
              rc = batters.find(key:Top_Bot,Key:mod(AB_Number-1,&nBattersPerGame)+1);
              do until(AB_Done);
                 Pitch_Number+1;
                 Index = ceil(100*uniform(&seed7*&date));
                 rc = pitch_dist.find();
                 if not AB_Done then
                 do;  /* continue the Plate Appearance */
                    Is_A_Ball = .;
                    Is_A_Strike = .;
                    if Result = 'Ball' then Is_A_Ball = 1;
                    else if find(Result,'strike','i') then Is_A_Strike = 1;
                    else if Result = 'Foul' and Strikes lt 2 then Is_A_Strike = 1;
                    Balls + Is_A_Ball;
                    Strikes + Is_A_Strike;
                    output pitches;
                    AB_Done = (Balls = 4 or Strikes = 3);
                    if Balls = 4 then
                    do;  /* set needed values for a walk */
                       Result = 'Walk';
                       Is_An_AB = 0;
                       Is_An_Out = 0;
                       Is_A_Hit = 0;
                       Bases = 1;
                       Runners_Advance_Factor = 1;
                    end; /* set needed values for a walk */
                    else if Strikes = 3 then
                    do;  /* set needed values for a strikeout */
                       Result = 'Strikeout';
                       Is_An_AB = 1;
                       Is_An_Out = 1;
                       Is_A_Hit = 0;
                       Bases = 0;
                    end; /* set needed values for a walk */
                 end; /* continue the Plate Appearance */
                 else output pitches;
                 if ab_done then
                 do;  /* create needed result fields */
                    onBase = 3 - nmiss(of runners(*));
                    Runs = 0;
                    if Bases then
                    do;  /* advance runners */
                       Left_On_Base = 0;
                       do i = dim(runners) to 1 by -1;
                          if runners(i) then
                          do;
                             if i+bases ge 4 then
                             do;  /* runners scored */
                                Runs + 1;
                                Runner_ID = runners(i);
                                output runs;
                             end; /* runners scored */
                             else runners(i+bases) = runners(i);
                             runners(i) = .;
                          end;
                       end;
                       if bases lt 4 then runners(bases) = batter_id;
                       else
                       do;  /* runners scored */
                          Runs + 1;
                          Runner_ID = Batter_ID;
                          output runs;
                       end; /* runners scored */ 
                    end; /* advance runners */
                    else Left_On_Base = onBase;		   
                    output atbats;
                    outs + Is_An_Out;
                 end; /* create needed result fields */
              end; /* AB loop */
           end; /* Outs Loop */
        end; /* Innings Loop */
     end; /* cheating a bit here - discuss with Paul */
    run;

    %if %sysfunc(exist(Bizarro.AtBats)) %then
    %do;  /* delete existing rows for these games */
       proc sql;
        delete from Bizarro.AtBats
        where Game_SK in (select distinct Game_SK from AtBats);
       quit;
    %end; /* delete existing rows for these games */

    proc append base = Bizarro.AtBats data = AtBats;
    run;

    %if %sysfunc(exist(Bizarro.Runs)) %then
    %do;  /* delete existing rows for these games */
       proc sql;
        delete from Bizarro.Runs
        where Game_SK in (select distinct Game_SK from AtBats);
       quit;
    %end; /* delete existing rows for these games */

    proc append base = Bizarro.Runs data = Runs;
    run;
    
    %if %sysfunc(exist(Bizarro.Pitches)) %then
    %do;  /* delete existing rows for these games */
       proc sql;
        delete from Bizarro.Pitches
        where Game_SK in (select distinct Game_SK from Pitches);
       quit;
    %end; /* delete existing rows for these games */

    proc append base = Bizarro.Pitches data = Pitches;
    run;

 %end;
%mend generatePitchAndPAData;
data bizarro.teams;
 /* Select team names from 100 most popular team names.
    Source: http://mascotdb.com/lists.php?id=5
 */
 keep League Team_SK Team_Name;
 retain League . Team_SK 100;
 if _n_ = 1 then
 do;  /* create hash table */
    declare hash teams();
    rc = teams.defineKey('Team_Name');
    rc = teams.defineData('Team_SK','Team_Name');
    rc = teams.defineDone();
 end; /* create hash table */
 infile datalines eof=lr;
 input Team_Name $16.;
 Team_SK + ceil(uniform(&seed1)*4);
 rc = teams.add();
 return;
 lr:
 declare hiter teamIter('teams');
 do i = 1 to 2*&nTeamsPerLeague;
    rc = teamIter.next();
    League = int((i-1)/16) + 1;
	output;
 end;
 *rc = teams.output(dataset:'showOrder');
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
;;
data bizarro.Positions_Dim;
 input Position_Code $2. +1 Position $16. +1 Count 8.;
 datalines;
SP Starting Pitcher 5
RP Relief Pitcher   5
C  Catcher          3
IF Infielder        4
OF Outfielder       3
UT Utility          2
;
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
data _null_;;
 set first_names
     last_names
     bizarro.positions_dim
 ;

 declare hash positionsDist();
 rc = positionsDist.defineKey('Index');
 rc = positionsDist.defineData('Index','Position_Code','Count');
 rc = positionsDist.defineDone();
 lr = 0;
 Index = 0;
 do until(lr);
    set bizarro.positions_dim end=lr;
    do i = 1 to Count;
       Index + 1;
       rc = positionsDist.add();
    end;
 end;
 rc = positionsDist.output(dataset:'positions');

 declare hash fname(dataset: 'first_names');
 rc = fname.defineKey('First_Name');
 rc = fname.defineData('First_Name');
 rc = fname.defineDone();
 declare hiter first_iter('fname');

 declare hash lname(dataset: 'last_names');
 rc = lname.defineKey('Last_Name');
 rc = lname.defineData('Last_Name');
 rc = lname.defineDone();
 declare hiter last_iter('lname');

 declare hash players();
 rc = players.defineKey('Arbtrary','First_Name','Last_Name');
 rc = players.defineData('First_Name','Last_Name','Position_Code');
 rc = players.defineDone();

 Arbtrary = 0;
 first_rc = first_iter.first();
 do while(first_rc = 0);
    last_rc = last_iter.first();
    do while(last_rc = 0);
       Arbtrary + 1;
       rc = positionsDist.find(Key:ceil(uniform(&seed2)*25));
       rc = players.add();
       last_rc = last_iter.next();
    end;
    first_rc = first_iter.next();
 end;
 rc = players.output(dataset:'bizarro.player_candidates');

run;

proc freq data = bizarro.player_candidates;
 title 'Quick Check of Distribution';
 tables position_code;
run;
title;
data positions_dim;
 set bizarro.positions_dim;
 retain DummyKey 1;
 drop position;
run;

data teams;
 set bizarro.teams(keep=team_sk);
 Assigned = 0;
run;

data _null_;
 
 if 0 then set positions_dim teams bizarro.player_candidates;
 retain Player_ID 10000;
 format Player_ID z5.;

 /* load the available players */
 declare hash available(dataset:"bizarro.player_candidates",multidata:"yes");
 rc = available.defineKey('Position_Code');
 rc = available.defineData('First_Name','Last_Name');
 rc = available.defineDone();

 /* load the hash table of positions */
 declare hash positions(dataset:"positions_dim",multidata:"yes");
 rc = positions.defineKey('DummyKey');
 rc = positions.defineData('Position_Code','Count');
 rc = positions.defineDone();

 /* load the list of teams */
 declare hash teams(dataset:'teams');
 rc = teams.defineKey('Team_SK');
 rc = teams.defineData('Team_SK','Assigned');
 rc = teams.defineDone();
 declare hiter teams_iter('teams');

 /* load the team data with slots for each position */
 declare hash players(ordered:'a');
 rc = players.defineKey('Player_ID');
 rc = players.defineData('Team_SK','Player_ID','First_Name','Last_Name','Position_Code');
 rc = players.defineDone();

 DummyKey = 1;
 pos_rc = positions.find();
 avail_rc = available.find();
 do until(pos_rc);
    teams_rc = teams_iter.first();
    do until(teams_rc);
       Needed = Count*2 + floor(uniform(&seed3)*2);
       do i = 1 to Needed;
          Player_ID + ceil(uniform(&seed4)*9);
          rc = players.add();
          avail_rc = available.find_next();
       end;
       Assigned = Assigned + Needed;
       rc = teams.replace();
       teams_rc = teams_iter.next();
    end;
    pos_rc = positions.find_next();
    avail_rc = available.find();
 end;
 /* Now add utility players to get each team to 50  players */
 Position_Code = 'UT';
 teams_rc = teams_iter.first();
 /* note that the hash iteration already pointing at the next available utility player
THIS MIGHT BE COINCIDENTAL?????
 */
 do until(teams_rc);
    do i = Assigned+1 to &nPlayersPerTeam;
       Player_ID + 1;
       avail_rc = available.find_next();
       rc = players.add();
    end;
    teams_rc = teams_iter.next();
 end;   
 rc = players.output(dataset:'bizarro.players');
run;

proc freq data = bizarro.players;
 title 'Quick Check of Position Distribution by Team';
 tables team_sk * position_code/norow nocol nopercent;
run;
data _null_;
 if 0 then set bizarro.teams;
 length Away_SK Home_SK 3;

 declare hash home_team(dataset:'bizarro.teams',multidata:'y');
 rc = home_team.defineKey('League');
 rc = home_team.defineData('League','Team_SK');
 rc = home_team.defineDone();

 declare hash away_team(dataset:'bizarro.teams',multidata:'y');
 rc = away_team.defineKey('League');
 rc = away_team.defineData('League','Team_SK');
 rc = away_team.defineDone();

 declare hash match_Ups();
 rc = match_Ups.defineKey('League','Home_SK','Away_SK');
 rc = match_Ups.defineData('League','Home_SK','Away_SK');
 rc = match_Ups.defineDone();
 
 do League = 1 to 2;                       /* loop thru Leagues */
    Home_rc = home_team.find();
    do while(Home_rc=0);                   /* loop thru Home Teams */
       Home_SK = Team_SK;
       Away_rc = away_team.find();         /* loop thru Away Teams for each home team */
       do while(Away_rc=0);
          Away_SK = Team_SK;
          if Home_SK ne Away_SK then
          do;
             addrc = match_Ups.add();
          end;
          Away_rc = away_team.find_next();
       end;                                /* loop thru Away Teams for each home team */
       Home_rc = home_team.find_next();
    end;                                   /* loop thru Home Teams */
 end;                                      /* loop thru Leagues */
 rc = match_Ups.output(dataset:'bizarro.Match_Ups');
 stop;
run;

title 'Check MatchUps Distribution';
data check;
 set bizarro.Match_Ups;
 Home_Away = 'Home';
 Team_SK = Home_SK;
 output;
 Home_Away = 'Away';
 Team_SK = Away_SK;
 output;
run;
proc freq data = check;
 tables Team_SK*Home_Away/norow nocol nopercent;
run;
title;
data match_ups;
 set bizarro.match_ups;
 do Group = 1 to 10;
    Arbitrary + 1;
    output;
 end;
run;

data _null_;
 if 0 then set bizarro.teams match_ups;
 format Date date9. Time Time5. Game_SK $hex32.;

 declare hash used(multidata:'yes',ordered:'a');
 rc = used.defineKey('League','Team_SK');
 rc = used.defineData();
 rc = used.defineDone();

 /* create an ordered hash of all the combinations */
 declare hash matchUps(dataset:'match_ups',multidata:'yes');
 rc = matchUps.defineKey('League','Arbitrary','Away_SK','Home_SK');
 rc = matchUps.defineData('League','Away_SK','Home_SK');
 rc = matchUps.defineDone();

 /* create a partially keyed hash inheriting the hash order from m */
 declare hash schedule(multidata:'yes',ordered:'a');
 rc = schedule.defineKey('League');
 rc = schedule.defineData('Game_SK','League','Away_SK','Home_SK','Date','Time');
 rc = schedule.defineDone();

 declare hiter miter('matchUps');
 copy_rc = miter.first();
 do while(copy_rc = 0);
    rc = schedule.add();
    copy_rc = miter.next();
 end ;

 do League = 1 to 2;
	rc = schedule.find();
	do D = "&seasonStartDate"d to "&seasonEndDate"d;
	   do T ='11:00'T, '16:00't;
          do until(used_items=16);
             Team_SK = Away_SK;
             if used.check() and Date = . then
             do;  /* not used yet */
                Team_SK = Home_SK;
                if used.check() then
                do;  /* not used yet */
                   rc=used.add();
                   Team_SK = Away_SK;
                   rc=used.add();
                   Random = 0;
                   Date = D;
                   Time = T;
                   Game_SK = md5(catx(':',League,Away_SK,Home_SK,Date,Time));
                   rc=schedule.replaceDup();
                end;
             end; /* not used yet */;
             used_items = used.num_items;
             rc = schedule.find_next();
          end;
          rc = used.clear();
          rc = schedule.find();
       end;
    end;
 end;

 /* replace this with hash iter on dates, and times? */
 rc = schedule.output(dataset:'schedule');

 stop;
run;

data bizarro.schedule;
 set schedule;
 where Date and Time; /* only keep those matchups assigned to a date and time */
run;

data check;
 set bizarro.schedule;
 HomeAway = 'Home';
 team_sk = home_sk;
 output;
 HomeAway = 'Away';
 team_sk = away_sk;
 output;
run;

proc freq data=check;
 title 'Check Schedule Distribution';
 by League;
 tables Team_SK*HomeAway/norow nocol nopercent;
run;
title;
%generateLineUps(from=&seasonStartDate,to=&seasonEndDate)
data bizarro.pitch_distribution;
 input Result $16. AB_Done Is_An_AB Is_An_Out Is_A_Hit Bases Runners_Advance_Factor From To;
 datalines;
Ball             0 . . . . .    1  33
Called Strike    0 . . . . .   34  48
Double           1 1 0 1 2 .7  49  51
Error            1 1 0 0 1 .4  52  52
Foul             0 . . . . .   53  68
Hit By Pitch     1 0 0 0 1 0   69  69
Home Run         1 1 0 1 4 0   70  71
Out              1 1 1 0 0 0   72  83
Single           1 1 0 1 1 .5  84  88
Swinging Strike  0 . . . . .   89  99
Triple           1 1 0 1 3 0  100 100
run;
%generatePitchAndPAData(from=&seasonStartDate,to=&seasonEndDate)
