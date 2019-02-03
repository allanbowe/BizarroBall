/* "Chapter 7 SCD 2.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if 0 then set template.Players_SCD2;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD2")
                    ,"bizarro.Players_SCD2"
                    ,"template.Players_SCD2"
                    )
                ,ordered:"A",multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Player_ID","Team_SK"
                  ,"First_Name","Last_Name"
                  ,"Position_Code","Bats","Throws"
                  ,"Start_Date","End_Date");
    scd.defineDone();
 end;  /* define the hash table */
 
 set bizarro.atbats
               (rename = (Batter_ID = Player_ID
                          Team_SK = _Team_SK
                          First_Name = _First_Name
                          Last_Name = _Last_Name
                          Position_Code = _Position_Code
                          Bats = _Bats
                          Throws = _Throws)
                ) end=lr;
 
 
 if scd.check() ne 0 then
 do;  /* need to add the player */
    scd.add(key: Player_ID
           ,data: Player_ID
           ,data: _Team_SK
           ,data: _First_Name
           ,data: _Last_Name
           ,data: _Position_Code
           ,data: _Bats
           ,data: _Throws
           ,data: Date
           ,data: &SCD_End_Date
           );
 end; /* need to add the player */
 else
 do;  /* check to see if there are changes */
 
    RC = scd.find();
    do while(RC = 0);
       if (Start_Date le Date le End_Date) then leave;
       RC = scd.find_next();
    end;
 
    if catx(":", Team_SK, First_Name, Last_Name
               , Position_Code, Bats, Throws) ne
       catx(":",_Team_SK,_First_Name,_Last_Name
               ,_Position_Code,_Bats,_Throws) then
    do;  /* date out prior record and add new one */;
       if RC = 0 then scd.replaceDup(data: Player_ID
                                    ,data: Team_SK
                                    ,data: First_Name
                                    ,data: Last_Name
                                    ,data: Position_Code
                                    ,data: Bats
                                    ,data: Throws
                                    ,data: Start_Date
                                    ,data: Date-1
                                    );
       scd.add(key: Player_ID
              ,data: Player_ID
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
 scd.output(dataset:"bizarro.Players_SCD2");
 stop;
run;
 
data tableLookup;
 /* Sample Lookup */
 if 0 then set bizarro.Players_SCD2;
 if _n_ = 1 then
 do;
    dcl hash scd(dataset:"bizarro.Players_SCD2"
                ,multidata:"Y");
    scd.defineKey("Player_ID");
    scd.defineData("Team_SK","Player_ID","First_Name"
                  ,"Last_Name","Position_Code","Bats"
                  ,"Throws","Start_Date","End_Date");
    scd.defineDone();
 end;
 infile datalines;
 attrib Date format = yymmdd10. informat = yymmdd10.;
 input Player_ID Date;
 RC = scd.find();
 do while(RC = 0);
    if (Start_Date le Date le End_Date) then leave;
    RC = scd.find_next();
 end;
 if RC ne 0 then call missing(Team_SK,First_Name
                             ,Last_Name,Position_Code
                             ,Bats,Throws
                             ,Start_Date,End_Date);
datalines;
10103 2017/03/23
10103 2017/07/26
99999 2017/04/15
10782 2017/03/22
10782 2017/03/21
run;