/* "Chapter 7 SCD 1.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash scd(dataset:
                 ifc(exist("bizarro.Players_SCD1")
                    ,"bizarro.Players_SCD1"
                    ,"template.Players_SCD1"
                    )
                ,ordered:"A");
    scd.defineKey("Player_ID");
    scd.defineData("Team_SK","Player_ID","First_Name"
                  ,"Last_Name","Position_Code");
    scd.defineDone();
 end; /* define the hash table */
 set bizarro.atbats(rename=(Batter_ID=Player_ID))
     end=lr;
 rc = scd.replace();
 if lr;
 scd.output(dataset:"Bizarro.Players_SCD1");
 stop;
 set template.players_scd1;
run;
 
data tableLookUp;
 /* sample lookup code */
 if 0 then set bizarro.players_SCD1;
 dcl hash scd(dataset:"bizarro.players_SCD1");
 scd.defineKey("Player_ID");
 scd.defineData("Team_SK","Player_ID","First_Name"
               ,"Last_Name","Position_Code");
 scd.defineDone();
 
 /* first a key with no data items */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 00001;
 RC = scd.find();
 output;
 /* now a key with a row of data items */
 call missing(Team_SK,First_Name,Last_Name
             ,Position_Code);
 Player_Id = 10103;
 RC = scd.find();
 output;
 stop;
run;