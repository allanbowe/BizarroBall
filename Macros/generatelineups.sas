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
