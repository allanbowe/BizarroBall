/* "generatepitchandpadata.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%macro generatePitchAndPAData
       (from =
       ,nweeks =
       );
 
 %local to;
 %let from = %sysfunc(inputn(&from,date9.));
 %let to = %eval(&from + &nweeks*7 - 1);
 
 %do date = &from %to &to;
 
    data _null_;
 
     if 0 then set template.AtBats template.Pitches template.Runs;
 
     retain Inning 1 Pitcher_ID . Date &date;
     length data_to_load $16;
     array runners(*) onFirst onSecond onThird;
 
     if _n_ = 1 then
     do;  /* define the needed hash tables */
 
        declare hash pitch_dist(ordered:"A");
        rc = pitch_dist.DefineKey("Index");
        rc = pitch_dist.DefineData("Index","Result","AB_Done","Is_An_Ab","Is_An_Out","Is_A_Hit","Is_An_OnBase"
                                  ,"Bases","Runners_Advance_Factor","Pitch_Distribution_SK");
        rc = pitch_dist.DefineDone();
        lr = 0;
        do until(lr);
           set bizarro.pitch_distribution end=lr;
           do Index = From to To;
              rc =pitch_dist.add();
           end;
        end;
        lr=0;
 
        declare hash hit_distance(dataset:"bizarro.hit_distance"
                                       || "(rename=(Pitch_Distribution_FK=Pitch_Distribution_SK))");
        rc = hit_distance.DefineKey("Pitch_Distribution_SK");
        rc = hit_distance.DefineData("MinDistance","MaxDistance");
        rc = hit_distance.DefineDone();
 
 
        declare hash batters(ordered:"A",multidata:"Y");
        rc = batters.DefineKey("Top_Bot","Batting_Order");
        rc = batters.DefineData("Team_SK","Top_Bot","Batter_ID","First_Name","Last_Name","Position_Code","Bats","Throws");
        rc = batters.DefineDone();
 
        declare hash pitchers(ordered:"D",multidata:"Y");
        rc = pitchers.DefineKey("Top_Bot");
        rc = pitchers.DefineData("Team_SK","Top_Bot","Pitcher_ID","First_Name","Last_Name","Position_Code","Pitcher_Bats","Pitcher_Throws");
        rc = pitchers.DefineDone();
 
        if exist("bizarro.Runs")
                 then data_to_load = "bizarro.Runs";
        else data_to_load = "template.Runs";
        declare hash facts_runs(dataset:data_to_load
                               ,ordered:"A"
                               ,multidata:"Y");
        facts_runs.DefineKey("Date","Game_SK");
        facts_runs.DefineData("Game_SK","Date","Batter_ID"
                             ,"Inning","Top_Bot"
                             ,"AB_Number","Runner_ID");
        facts_runs.DefineDone();
 
        if exist("bizarro.Pitches") then data_to_load = "bizarro.Pitches";
        else data_to_load = "template.Pitches";
        declare hash facts_pitches(dataset:data_to_load,ordered:"A",multidata:"Y");
        facts_pitches.DefineKey("Date","Game_SK");
        facts_pitches.DefineData("Game_SK","Date","Team_SK","Pitcher_ID","Pitcher_First_Name","Pitcher_Last_Name"
                                ,"Pitcher_Bats","Pitcher_Throws","Pitcher_Type","Inning","Top_Bot","Result","AB_Number","Outs"
                                ,"Balls","Strikes","Pitch_Number","Is_A_Ball","Is_A_Strike","onBase");
        facts_pitches.DefineDone();
 
        if exist("bizarro.AtBats") then data_to_load = "bizarro.AtBats";
        else data_to_load = "template.AtBats";
        declare hash facts_atbats(dataset:data_to_load,ordered:"A",multidata:"Y");
        facts_atbats.DefineKey("Date","Game_SK");
        facts_atbats.DefineData("Game_SK","Date","Time","League","Away_SK","Home_SK","Team_SK"
                               ,"Batter_ID","First_Name","Last_Name","Position_Code","Inning"
                               ,"Top_Bot","Bats","Throws","AB_Number","Result","Direction","Distance"
                               ,"Outs","Balls","Strikes","onFirst","onSecond","onThird","onBase"
                               ,"Left_On_Base","Runs","Is_An_AB","Is_An_Out","Is_A_Hit","Is_An_OnBase"
                               ,"Bases","Number_of_Pitches");
        facts_atbats.DefineDone();
 
     end; /* define the needed hash tables */
 
     if lr then
     do;  /* output the updated fact tables */
        facts_runs.output(dataset:"bizarro.Runs");
        facts_pitches.output(dataset:"bizarro.Pitches");
        facts_atbats.output(dataset:"bizarro.AtBats");
     end; /* output the updated fact tables */
 
     set bizarro.games end=lr;
     where date=&date;
     League = League_SK;  /* fix/hack for missed rename */
 
     if game_sk ne lag(game_sk) then
     do;  /* delete existing rows for this game */
        if facts_runs.check() = 0 then facts_runs.remove();
        if facts_pitches.check() = 0 then facts_pitches.remove();
        if facts_atbats.check() = 0 then facts_atbats.remove();
     end; /* delete existing rows for this game */
 
     /* load the batter data for this game */
     rc = batters.clear();
     rc = pitchers.clear();
     Top_Bot = "T";
     do team_sk = away_sk, home_sk;
        do until(_iorc_ ne 0);
           set bizarro.LineUps key = LineUp;
           if _iorc_ = 0 then
           do;  /* row found and read */
              rc = batters.add(Key:Top_Bot,Key:Batting_Order,Data:Team_SK,Data:Top_Bot,Data:Player_ID,Data:First_Name,Data:Last_Name,Data:Position_Code,Data:Bats,Data:Throws);
              if Position_Code in ("SP" "RP") then rc = pitchers.add(Key:Top_Bot,Data:Team_SK,Data:Top_Bot,Data:Player_ID,Data:First_Name,Data:Last_Name,Data:Position_Code,Data:Bats,Data:Throws);
           end; /* row found and read */
        end;
        Top_Bot = "B";
     end;
 
     Team_SK = .;
 
     _error_ = 0;  /* suppress the error message when the indexed read failed as expected */
 
     array _halfInning(2) ab_t ab_b;
     call missing(ab_t,ab_b);
 
     do Inning = 1 to 9;
        ab_index = 0;
        do Top_Bot = "T", "B";
           ab_index + 1;
           rc = pitchers.find(key:Top_Bot);
 
           rc = pitchers.has_next(result:not_last);
           if inning ge 6 and not_last then
           do;
              rc=pitchers.removeDup();
              pitchers.find(key:Top_Bot);
           end;
 
           Pitcher_First_Name = First_Name;
           Pitcher_Last_Name = Last_Name;
           Pitcher_Type = Position_Code;
           outs = 0;
           call missing(onFirst,onSecond,onThird);
           do until(outs=3);
              Is_An_Out = .;
              Balls = 0;
              Strikes = 0;
              Pitch_Number = 0;
              _halfInning(ab_index) + 1;
              AB_Number = _halfInning(ab_index);
              rc = batters.find(key:Top_Bot,Key:mod(AB_Number-1,&nBattersPerGame)+1);
 
           rc = batters.has_next(result:not_last);
           if mod(AB_Number,&nBattersPerGame)= 0 and inning ge 6 and not_last then
           do;
              rc=batters.removeDup();
              batters.find(key:Top_Bot,Key:mod(AB_Number-1,&nBattersPerGame)+1);
           end;
 
              do until(AB_Done);
                 Pitch_Number+1;
                 Index = ceil(100*uniform(&seed6*&date));
                 rc = pitch_dist.find();
                 if not AB_Done then
                 do;  /* continue the Plate Appearance */
                    call missing(Is_A_Ball,Is_A_Strike);
                    if Result = "Ball" then Is_A_Ball = 1;
                    else if find(Result,"strike","i") then Is_A_Strike = 1;
                    else if Result = "Foul" and Strikes lt 2 then Is_A_Strike = 1;
                    Balls + Is_A_Ball;
                    Strikes + Is_A_Strike;
                    facts_pitches.add();
                    AB_Done = (Balls = 4 or Strikes = 3);
                    if Balls = 4 then
                    do;  /* set needed values for a walk */
                       Result = "Walk";
                       call missing(Is_An_AB,Is_An_Out,Is_A_Hit);
                       Bases = 1;
                       Runners_Advance_Factor = 1;
                       Is_An_OnBase = 1;
                    end; /* set needed values for a walk */
                    else if Strikes = 3 then
                    do;  /* set needed values for a strikeout */
                       Result = "Strikeout";
                       Is_An_AB = 1;
                       Is_An_Out = 1;
                       Is_An_OnBase = 0;
                       call missing(Is_A_Hit,Bases);
                    end; /* set needed values for a walk */
                 end; /* continue the Plate Appearance */
                 else facts_pitches.add();
                 if ab_done then
                 do;  /* create needed result fields */
                    call missing(MinDistance,MaxDistance,Direction,Distance);
                    if hit_distance.find()=0 then
                    do;  /* calculate direction and distance */
				       Direction = ceil(18*uniform(&seed7*&date));
				       Distance = MinDistance + ceil((MaxDistance-MinDistance)*uniform(&seed8*&date));
                    end; /* calculate direction and distance */
                    onBase = 3 - nmiss(of runners(*));
                    Runs = 0;
                    if Bases then
                    do;  /* advance runners */
                       Left_On_Base = 0;
                       Advance = Bases + (Runners_Advance_Factor > uniform(&seed9*Date));
                       do i = dim(runners) to 1 by -1;
                          if runners(i) then
                          do;  /* advance runner on this base */
                             if i+Advance ge 4 then
                             do;  /* runners scored */
                                Runs + 1;
                                Runner_ID = runners(i);
                                facts_runs.add();
                             end; /* runners scored */
                             else runners(i+Advance) = runners(i);
                             runners(i) = .;
                          end; /* advance runner on this base */
                       end;
                       if bases lt 4 then runners(bases) = batter_id;
                       else
                       do;  /* runners scored */
                          Runs + 1;
                          Runner_ID = Batter_ID;
                          facts_runs.add();
                       end; /* runners scored */
                    end; /* advance runners */
                    else Left_On_Base = onBase;
                    Number_of_Pitches = Pitch_Number;	
                    facts_atbats.add();
                    outs + Is_An_Out;
                 end; /* create needed result fields */
              end; /* AB loop */
           end; /* Outs Loop */
        end; /* Innings Loop */
     end; /* cheating a bit here - discuss with Paul */
    run;
 %end;
%mend generatePitchAndPAData;
