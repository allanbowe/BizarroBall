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
