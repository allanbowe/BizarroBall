/* "Chapter 8 Median.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 dcl hash medianDist(dataset:"dw.AtBats(where=(Distance gt 0))"
                    ,multidata:"Y"
                    ,ordered:"A");
 medianDist.defineKey("Distance");
 medianDist.defineDone();
 dcl hiter iterM("medianDist");
 iterM.first();
 do i = 1 to .5*medianDist.num_items - 1;
    iterM.next();
 end;
 /* could add logic here to interpolate if needed */
 put "The Median is " Distance;
 stop;
 set dw.AtBats(keep=Distance);
run;
