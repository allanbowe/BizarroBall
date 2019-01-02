/**
  @file
  @brief Generates the At Bat, Pitch and Runner data used in many of the examples.
  @author Paul M. Dorfman and Don Henderson
**/

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
