/* "Chapter 7 Update Star Schema DW.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 %createHash(hashTable=AtBats)
 %createHash(hashTable=Pitches)
 %createHash(hashTable=Runs)
 %createHash(hashTable=Games)
 %createHash(hashTable=Players_Positions_Played)
 %createHash(hashTable=Players)
 
 dcl hash uniqueGames();
 uniqueGames.defineKey("Game_SK"
                      ,"Player_ID"
                      ,"Position_Code");
 uniqueGames.defineDone();
 
 lr = 0;
 do until(lr);
    set bizarro.AtBats(rename = (Team_SK = _Team_SK
                                 First_Name = _First_Name
                                 Last_Name = _Last_Name
                                 Bats = _Bats
                                 Throws = _Throws)
                                ) end=lr;
    if game_sk ne lag(game_sk) and _AtBats.check() = 0
       then _AtBats.remove();
    _AtBats.add();
    link Games_SCD;
    Player_ID = Batter_ID;
    link Positions_Played_SCD;
    link Players_SCD;
 end;
 _AtBats.output(dataset:"dw.AtBats");
 
 lr = 0;
 do until(lr);
    set bizarro.Pitches end=lr;
    if game_sk ne lag(game_sk) and _Pitches.check() = 0
       then _Pitches.remove();
    _Pitches.add();
    Player_ID = Pitcher_ID;
    _Team_SK = Team_SK;
    _First_Name = Pitcher_First_Name;
    _Last_Name = Pitcher_Last_Name;
    _Bats = Pitcher_Bats;
    _Throws = Pitcher_Throws;
    link Players_SCD;
    Position_Code = Pitcher_Type;
    link Positions_Played_SCD;
 end;
 _Pitches.output(dataset:"dw.Pitches");
 
 lr = 0;
 do until(lr);
    set bizarro.Runs end=lr;
    if game_sk ne lag(game_sk) and _Runs.check() = 0
       then _Runs.remove();
    _Runs.add();
 end;
 _Runs.output(dataset:"dw.Runs");
 
 /* output the updated dimension tables */
 _games.output(dataset:"dw.Games");
 _Players_Positions_Played.output
                          (dataset:"dw.Players_Positions_Played");
 _Players.output(dataset:"dw.Players");
 stop;
 
 Games_SCD:
  Year = Year(Date);
  Month = Month(Date);
  DayOfWeek = weekday(Date);
  _games.replace();
 return;
 
 Positions_Played_SCD:
  if _Players_Positions_Played.find() ne 0
     then call missing(First,Second,Short,Third,Left
                      ,Center,Right,Catcher,Pitcher);
  select(Position_Code);
     when("1B") First        + (uniqueGames.add() = 0);
     when("2B") Second       + (uniqueGames.add() = 0);
     when("SS") Short        + (uniqueGames.add() = 0);
     when("3B") Third        + (uniqueGames.add() = 0);
     when("LF") Left         + (uniqueGames.add() = 0);
     when("CF") Center       + (uniqueGames.add() = 0);
     when("RF") Right        + (uniqueGames.add() = 0);
     when("C" ) Catcher      + (uniqueGames.add() = 0);
     when("SP") Pitcher      + (uniqueGames.add() = 0);
     when("RP") Pitcher      + (uniqueGames.add() = 0);
     when("PH") Pinch_Hitter + (uniqueGames.add() = 0);
     otherwise;
  end;
  _Players_Positions_Played.replace();
 return;
 
 Players_SCD:
  if _Players.check() ne 0 then
  do;  /* need to add the player */
     _Players.add(key: Player_ID
                 ,data: Player_ID
                 ,data: _Team_SK
                 ,data: _First_Name
                 ,data: _Last_Name
                 ,data: _Bats
                 ,data: _Throws
                 ,data: Date
                 ,data: &SCD_End_Date
                 );
  end; /* need to add the player */
  else
  do;  /* check to see if there are changes */
 
     RC = _Players.find();
     do while(RC = 0);
        if (Start_Date le Date le End_Date) then leave;
        RC = _Players.find_next();
     end;
 
     if catx(":", Team_SK, First_Name, Last_Name
                , Bats, Throws) ne
        catx(":",_Team_SK,_First_Name,_Last_Name
                ,_Bats,_Throws) then
     do;  /* date out prior record and add new one */
        if RC = 0 then
                  _Players.replaceDup(data: Player_ID
                                     ,data: Team_SK
                                     ,data: First_Name
                                     ,data: Last_Name
                                     ,data: Bats
                                     ,data: Throws
                                     ,data: Start_Date
                                     ,data: Date-1
                                     );
        _Players.add(key: Player_ID
                    ,data: Player_ID
                    ,data: _Team_SK
                    ,data: _First_Name
                    ,data: _Last_Name
                    ,data: _Bats
                    ,data: _Throws
                    ,data: Date
                    ,data: &SCD_End_Date
                    );
     end; /* date out prior record and add new one */;
  end;  /* check to see if there are changes */
 return;
run;
