/**
  @file
  @brief Uses the SAS hash object to create a filtered/subset
    Cartesian product of all possible matchups within a given league (ie, 
    each team playing each other team up to a fixed number of times)
  @author Paul M. Dorfman and Don Henderson
**/

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
