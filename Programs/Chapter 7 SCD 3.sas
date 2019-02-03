/* "Chapter 7 SCD 3.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD3;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD3")
                    ,"bizarro.Players_SCD3"
                    ,"template.Players_SCD3"
                    )
                ,ordered:"A",multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Debut_Team_SK","Team_SK"
                  ,"First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.atbats(rename=(Batter_ID = Player_ID))
     end=lr;
 _Team_SK = Team_SK;
 if scd.find() then scd.add(Key:Player_ID
                           ,Data:Player_ID
                           ,Data:Team_SK
                           ,Data:Team_SK
                           ,Data:First_Name
                           ,Data:Last_Name
                           ,Data:Position_Code
                           ,Data:Bats
                           ,Data:Throws
                           );
 else scd.replace(Key:Player_ID
                 ,Data:Player_ID
                 ,Data:Debut_Team_SK
                 ,Data:_Team_SK
                 ,Data:First_Name
                 ,Data:Last_Name
                 ,Data:Position_Code
                 ,Data:Bats
                 ,Data:Throws
                 );
 if lr;
 scd.output(dataset:"bizarro.Players_SCD3");
run;