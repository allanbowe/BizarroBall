/* "Chapter 5 GenerateSchedule.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 retain Team_SK Team1_SK Team2_SK .; /* define hash data items */
 format Date yymmdd10.;
 
 declare hash team1(dataset:"bizarro.teams(rename=(Team_SK=Team1_SK))",multidata:"y");
 rc = team1.defineKey("League_SK");
 rc = team1.defineData("League_SK","Team1_SK");
 rc = team1.defineDone();
 
 declare hash team2(dataset:"bizarro.teams(rename=(Team_SK=Team2_SK))",multidata:"y");
 rc = team2.defineKey("League_SK");
 rc = team2.defineData("League_SK","Team2_SK");
 rc = team2.defineDone();
 
 declare hash matchUps(multidata:"y");
 rc = matchUps.defineKey("League_SK");
 rc = matchUps.defineData("League_SK","Team1_SK","Team2_SK");
 rc = matchUps.defineDone();
 
 declare hash used();
 rc = used.defineKey("League_SK","Team_SK");
 rc = used.defineData("League_SK","Team_SK");
 rc = used.defineDone();
 
 declare hash schedule();
 rc = schedule.defineKey("League_SK","Team1_SK","Team2_SK");
 rc = schedule.defineData("League_SK","Team1_SK","Team2_SK","Date","Home");
 rc = schedule.defineDone();
 
 do League_SK = 1 to 2;                     /* loop thru Leagues */
    Team1_rc = team1.find();
    do while(Team1_rc=0);                /* loop thru Team1 Teams */
       Team2_rc = team2.find();
       do while(Team2_rc=0);             /* loop thru Team2 Teams for each Team1 team */
          if Team2_SK ne Team1_SK then
          do;
             addrc = matchUps.add();
          end;
          Team2_rc = team2.find_next();
       end;                              /* loop thru Team2 Teams for each Team1 team */
       Team1_rc = team1.find_next();
    end;                                 /* loop thru Team1 Teams */
 end;                                    /* loop thru Leagues */
 
 do League_SK = 1 to 2;                             /* loop thru Leagues */
    Date = "&seasonStartDate"d - 3;
    do Combo = 1 to &nWeeksSeason;             /* create the matchup sets */
       if mod(combo,2) = 1 then Date + 3;
       else Date + 4;
       games = 0;
       matchUps_rc = matchUps.find();
       do while(matchUps_rc = 0 and games lt &nTeamsPerLeague/2);
          if    used.check(key:League_SK,key:Team1_SK) ne 0
            and used.check(key:League_SK,key:Team2_SK) ne 0
          then
          do;  /* combinations not yet used */
             Home = ceil(uniform(&seed4)*2);
             if schedule.add() = 0 then
             do;  /* add to schedule */
                games + 1;
                rc = used.add(Key:League_SK,Key:Team1_SK,Data:League_SK,Data:Team1_SK);
                rc = used.add(Key:League_SK,Key:Team2_SK,Data:League_SK,Data:Team1_SK);
             end; /* add to schedule */
          end; /* combinations not yet used */
          matchUps_rc = matchUps.find_next();
       end;
       used.clear();                             /* loop thru matchups */
    end;/* loop thru Leagues */
 end;
 schedule.output(dataset:"Games");
 stop;
run;
 
proc sort data = games out = games;
 by League_SK Date;
run;
 
data bizarro.games;
 if 0 then set template.games;
 drop Team1_SK Team2_SK Home D;
 format Time Timeampm8.;
 set games;
 League = League_SK; /* fix for rename issue found post-publication */
 D = Date;
 retain D;
 array _homeaway team1_sk team2_sk;
 Home_SK = _homeaway(Home);
 Away_SK = _homeaway(3-Home);
 do Date = D to D+2;
    Year = Year(Date);
    Month = Month(Date);
    DayOfWeek = weekday(Date);
    if DayOfWeek = 5 then Time = "16:00"t;
    else if DayOfWeek = 1 then Time = "13:00"t;
    else time = "19:00"t;
    Game_SK = md5(catx(":",League_SK,Away_SK,Home_SK,Date,Time));
    output;
 end;
 /* Reverse home/away for second half of the season */
 D + 7*&nWeeksSeason/2;
 Home_SK = _homeaway(3-Home);
 Away_SK = _homeaway(Home);
 do Date = D to D+2;
    Year = Year(Date);
    Month = Month(Date);
    DayOfWeek = weekday(Date);
    Game_SK = md5(catx(":",League_SK,Away_SK,Home_SK,Date,Time));
    output;
 end;
run;
