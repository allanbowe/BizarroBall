/* "Chapter 9 HoH Percentiles.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Percentiles;
 keep Variable Percentile Value;
 length Variable $32;
 format Percentile percent5. Value Best.;
 dcl hash HoH(ordered:"A");
 HoH.defineKey ("Variable");
 HoH.defineData ("H","ITER","Variable");
 HoH.defineDone();
 dcl hash h();
 dcl hiter iter;
 
 h = _new_ hash(dataset:"dw.AtBats(where=(Value) rename=(Distance=Value))"
               ,multidata:"Y",ordered:"A");
 h.defineKey("Value");
 h.defineDone();
 iter = _new_ hiter("H");
 Variable = "Distance";
 HoH.add();
 
 h = _new_ hash(dataset:"dw.AtBats(where=(Value) rename=(Direction=Value))"
                ,multidata:"Y",ordered:"A");
 h.defineKey("Value");
 h.defineDone();
 iter = _new_ hiter("H");
 Variable = "Direction";
 HoH.add();
 
 array _ptiles(6) _temporary_ (.05 .1 .25 .5 .75 .95);
 call sortn(of _ptiles(*));
 
 dcl hiter HoH_Iter("HoH");
 do while (HoH_Iter.next() = 0);
    Counter = 0;
    num_items = h.num_items;
    do i = 1 to dim(_ptiles);
       Percentile = _ptiles(i);
       do while (Counter lt Percentile*num_items);
          Counter + 1;
          iter.next();
       end;
       /* could add logic here to read next value to interpolate */
       output;
    end;
 end;
 stop;
 Value = 0;
run;