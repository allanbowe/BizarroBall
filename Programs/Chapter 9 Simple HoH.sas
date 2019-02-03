/* "Chapter 9 Simple HoH.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 length Table $41;
 dcl hash HoH();
 HoH.defineKey ("Table");
 HoH.defineData("H","Table");
 HoH.defineDone();
 dcl hash h();
 
 Table = "DW.AtBats";
 h = _new_ hash(dataset:Table);
 h.defineKey("Game_SK","Inning","Top_Bot","AB_Number");
 h.defineData("Result");
 h.defineDone();
 HoH.add();
 
 Table = "DW.Pitches";
 h = _new_ hash(dataset:Table);
 h.defineKey("Game_SK","Inning","Top_Bot","AB_Number","Pitch_Number");
 h.defineData("Result");
 h.defineDone();
 HoH.add();
 
 dcl hiter i_HoH("HoH");
 do while (i_HoH.next() = 0);
    Rows = h.num_items;
    put (Table Rows)(=);
 end;
 stop;
 set dw.pitches(keep = Game_SK Inning Top_Bot AB_Number Pitch_Number Result);
run;
