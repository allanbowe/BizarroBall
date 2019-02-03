/* "Chapter 7 SCD 3 w Facts.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD3_Facts;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
           ifc(exist("bizarro.Players_SCD3_Facts")
              ,"bizarro.Players_SCD3_Facts"
              ,"template.Players_SCD3_Facts"
              )
                ,ordered:"A");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Team_SK"
                  ,"First_Name","Last_Name"
                  ,"First","Second","Short","Third"
                  ,"Left","Center","Right","Catcher"
                  ,"Pitcher","Pinch_Hitter");
    scd.defineDone();
    dcl hash uniqueGames();
    uniqueGames.defineKey("Game_SK"
                         ,"Player_ID"
                         ,"Position_Code");
    uniqueGames.defineDone();
 end; /* define the hash table */
 set bizarro.AtBats(rename = (Batter_ID = Player_ID))
     end=lr;
 if scd.find() ne 0 then
    call missing(First,Second,Short,Third
                ,Left,Center,Right,Catcher
                ,Pitcher,Pinch_Hitter);
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
 scd.replace();
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD3_Facts");
run;