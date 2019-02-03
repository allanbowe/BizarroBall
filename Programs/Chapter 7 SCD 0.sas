/* "Chapter 7 SCD 0.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD0")
                    ,"bizarro.Players_SCD0"
                    ,"template.Players_SCD0"
                    )
                ,ordered:"A");
    scd.defineKey("Player_ID");
    scd.defineData("Team_SK","Player_ID","First_Name"
                  ,"Last_Name","Position_Code");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.AtBats(rename=(Batter_ID=Player_ID))
     end=lr;
 RC = scd.add();
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD0");
 stop;
 set template.Players_SCD0;
run;
 
data tableLookup;
 /* sample lookup code */
 if 0 then set bizarro.Players_SCD0;
 dcl hash scd(dataset:"bizarro.Players_SCD0");
 scd.defineKey("Player_ID");
 scd.defineData("Team_SK","Player_ID","First_Name"
               ,"Last_Name","Position_Code");
 scd.defineDone();
 
 /* first a key not yet in the table */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 00001;
 RC = scd.find();
 output;
 
 /* now a key already in the table */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 10103;
 RC = scd.find();
 output;
 stop;
run;