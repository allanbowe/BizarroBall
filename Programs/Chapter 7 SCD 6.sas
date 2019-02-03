/* "Chapter 7 SCD 6.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD6;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD6")
                    ,"bizarro.Players_SCD6"
                    ,"template.Players_SCD6"
                    )
                ,ordered:"A",multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Active","SubKey"
                  ,"Team_SK","First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws"
                  ,"Start_Date","End_Date");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.atbats
               (rename = (Batter_ID = Player_ID
                          Team_SK = _Team_SK
                          First_Name = _First_Name
                          Last_Name = _Last_Name
                          Position_Code = _Position_Code
                          Bats = _Bats
                          Throws = _Throws)
               ) end=lr;
 if scd.check(Key:Player_ID) ne 0 then
 do;  /* player is new */
    scd.add(key: Player_ID
           ,data: Player_ID
           ,data: 1
           ,data: 1
           ,data: _Team_SK
           ,data: _First_Name
           ,data: _Last_Name
           ,data: _Position_Code
           ,data: _Bats
           ,data: _Throws
           ,data: Date
           ,data: &SCD_End_Date
           );
 end; /* player is new */
 else
 do;  /* check to see if there are changes */
 
    RC = scd.find();
    do while(RC = 0);
       if (Start_Date le Date le End_Date) then leave;
       RC = scd.find_next();
    end;
    if RC ne 0 then
       call missing(Team_SK,First_Name,Last_Name
                   ,Position_Code,Bats,Throws);
 
    if catx(":", Team_SK, First_Name, Last_Name
               , Position_Code, Bats, Throws) ne
       catx(":",_Team_SK,_First_Name,_Last_Name
               ,_Position_Code,_Bats,_Throws) then
    do;  /* date out prior record and add new one */;
 
       if RC = 0 then /* date out active record */
          scd.replaceDup(data: Player_ID
                        ,data: 0
                        ,data: SubKey
                        ,data: Team_SK
                        ,data: First_Name
                        ,data: Last_Name
                        ,data: Position_Code
                        ,data: Bats
                        ,data: Throws
                        ,data: Start_Date
                        ,data: Date - 1
                        );
 
       /* add row with the next autonumber value */
       _SubKey = 0;
       RC = scd.find();
       do while(RC = 0);
          RC = scd.find_next();
          _SubKey = max(_SubKey,SubKey);
       end;
       scd.add(key: Player_ID
              ,data: Player_ID
              ,data: 1
              ,data: _SubKey + 1
              ,data: _Team_SK
              ,data: _First_Name
              ,data: _Last_Name
              ,data: _Position_Code
              ,data: _Bats
              ,data: _Throws
              ,data: Date
              ,data: &SCD_End_Date
              );
    end; /* date out prior record and add new one */;
 end;  /* check to see if there are changes */
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD6"
     || "(index=(SCD6=(Player_ID Active SubKey)))");
run;
 
data tableLookup;
 /* Sample Lookup */
 retain Player_ID;
 if 0 then set bizarro.Players_SCD6(drop=Subkey);
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:"bizarro.Players_SCD6"
                ,multidata:"Y",ordered:"D");
    scd.defineKey("Player_ID","Active");
    scd.defineData("Team_SK","Player_ID","Active"
                  ,"First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws"
                  ,"Start_Date","End_Date");
    scd.defineDone();
 end; /* define the hash table */
 infile datalines;
 attrib Date format = yymmdd10. informat = yymmdd10.;
 input Player_ID Date;
 RC = scd.find(Key:Player_ID,Key:1);
 if RC = 0 and (Start_Date le Date le End_Date)
 then;
 else
 do;  /* search the inactive rows */
    RC = scd.find(Key:Player_ID,Key:0);
    do while(RC = 0);
       if (Start_Date le Date le End_Date) then leave;
       RC = scd.find_next();
    end;
 end; /* search the inactive rows */
 if RC ne 0 then
            call missing(Team_SK,Active,First_Name
                        ,Last_Name,Position_Code,Bats
                        ,Throws,Start_Date,End_Date);
datalines;
10103 2017/10/15
10103 2017/03/23
99999 2017/03/15
10782 2017/03/22
10782 2017/03/21
run;