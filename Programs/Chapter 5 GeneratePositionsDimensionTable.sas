/* "Chapter 5 GeneratePositionsDimensionTable.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 infile datalines eof=readall;
 /* Hash Object as an in memory table */
 if _n_ = 1 then
 do;  /* define just once */
    declare hash positions(ordered:"a");
    positions.defineKey("Position_Grp_SK");
    positions.defineData("Position_Grp_SK","Position_Code","Position","Count","Starters");
    positions.defineDone();
 end; /* define just once */
 informat Position_Code $3. Position $17. Count Starters 8.;
 label Position_Grp_SK = "Position Group Surrogate Key"
       Position_Code = "Position Code"
       Position = "Position Description"
       Count = "Number of Players"
       Starters = "Number of Starters"
 ;
 input Position_Code Position & Count Starters;
 Position_Grp_SK + 1;
 positions.add(); /* could also use positions.add() or positions.ref() */
 return;
 readall:
    /* output a sorted version of our table */
    positions.output(dataset:"Bizarro.Positions");
    return;
 datalines;
SP  Starting Pitcher   4 1
RP  Relief Pitcher     6 0
C   Catcher            2 1
CIF Corner Infielder   3 2
MIF Middle Infielder   3 2
COF Corner Outfielder  3 2
CF  Center Fielder     2 1
UT  Utility            2 0
;
data  _null_;
 infile datalines eof=readall;
 /* Hash Object as an in memory table */
 if _n_ = 1 then
 do;  /* define just once */
    declare hash positions(ordered:"a");
    positions.defineKey("Position_SK");
    positions.defineData("Position_SK","Position_Grp_FK","Position_Code","Position");
    positions.defineDone();
 end; /* define just once */
 informat Position_Grp_FK 8. Position_Code $3. Position $17.;
 label Position_SK = "Position Surrogate Key"
       Position_Grp_FK = "Position Group Surrogate Key"
       Position_Code = "Position Code"
       Position = "Position Description"
 
 ;
 input Position_Grp_FK Position_Code Position &;
 Position_SK + 1;
 positions.add(); /* could also use positions.add() or positions.ref() */
 return;
 readall:
    /* output a sorted version of our table */
    positions.output(dataset:"Bizarro.Positions_Snowflake");
    return;
 datalines;
4 1B First Baseman
4 3B Third Baseman
5 2B Second Baseman
5 SS Shortstop
6 LF Left Fielder
6 RF Right Fielder
;
