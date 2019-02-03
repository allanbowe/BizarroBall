/* "Chapter 8 Percentiles.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Percentiles;
 keep Percentile Distance;
 format Percentile percent5.;
 dcl hash ptiles(dataset:"dw.AtBats (where=(Distance gt .))"
                ,multidata:"Y",ordered:"A");
 ptiles.defineKey("Distance");
 ptiles.defineDone();
 dcl hiter iterP("ptiles");
 array _ptiles(6) _temporary_ (.5 .05 .1 .25 .75 .95);
 call sortn(of _ptiles(*));
 num_items = ptiles.num_items;
 do i = 1 to dim(_ptiles);
    Percentile = _ptiles(i);
    do while (Counter lt Percentile*num_items);
       Counter + 1;
       iterP.next();
    end;
    /* could add logic here to read
       next value to interpolate */
    output;
 end;
 stop;
 set dw.AtBats;
run;