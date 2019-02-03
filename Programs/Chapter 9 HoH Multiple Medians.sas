/* "Chapter 9 HoH Multiple Medians.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sql;
 create table HoH_List as
 select distinct "Distance " as Field
       ,Result
 from dw.Atbats
 where Distance is not null
 outer union corr
 select distinct "Direction" as Field
       ,Result
 from dw.Atbats
 where Distance is not null
 ;
quit;
 
data Medians;
 if 0 then set dw.AtBats(keep=Result);
 length Median 8;
 keep Result Field Median;
 dcl hash HoH(ordered:"A");
 HoH.defineKey ("Result","Field");
 HoH.defineData ("Result","Field","h","iter");
 HoH.defineDone();
 dcl hash h();
 dcl hiter iter;
 
 do until(lr);
    set HoH_List end = lr;
    h = _new_ hash(dataset:cats("dw.AtBats"
                               || "(where=(Result='"
                               ,Result
                               ,"')"
                               ,"rename=("
                               ,field
                               ,"=Median))")
               ,multidata:"Y",ordered:"A");
    h.defineKey("Median");
    h.defineDone();
    iter = _new_ hiter("h");
    HoH.add();
 end;
 
 dcl hiter HoH_Iter("HoH");
 do while (HoH_Iter.next() = 0);
    Count = h.num_items;
    iter.first();
    do i = 1 to .5*Count - 1;
      iter.next();
    end;
    /* could add logic here to interpolate if needed */
    output;
 end;
 stop;
run;