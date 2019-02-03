/* "Chapter 9 HoH MeanMedianMode.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Ptiles;
 input Percentile;
 Metric = put(Percentile,percent8.);
 datalines;
.05
.1
.25
.5
.75
.95
;
 
data Variables;
 infile datalines;
 length Variable $32;
 input Variable $32.;
 datalines;
Distance
Direction
;
 
proc sql noprint;
 select distinct Variable
        into:Vars separated by ' '
 from Variables;
quit;
 
data Distributions(keep=Variable Value Count Percent Cumulative Cum_Percent);
 length Variable $32 Value 8 Metric $8;
 format Count Cumulative total comma12. Percent Cum_Percent percent7.2;
 array _Variables(*) &Vars;
 
 dcl hash ptiles(dataset:"ptiles",ordered:"A");
 ptiles.defineKey("Percentile");
 ptiles.defineData("Percentile","Metric");
 ptiles.defineDone();
 dcl hiter iter_ptiles("ptiles");
 
 dcl hash results(ordered:"A",multidata:"Y");
 results.defineKey("Variable","Metric");
 results.defineData("Variable","Metric","Value");
 results.defineDone();
 
 dcl hash HoH(ordered:"A");
 HoH.defineKey ("I");
 HoH.defineData ("H","ITER","Variable","Total","Sum","maxCount");
 HoH.defineDone();
 dcl hash h();
 dcl hiter iter;
 
 do I = 1 to dim(_Variables);
    h = _new_ hash(ordered:"A");
    h.defineKey(vname(_Variables(i)));
    h.defineData(vname(_Variables(i)),"Count");
    h.defineDone();
    iter = _new_ hiter("H");
    Variable = vname(_Variables(i));
    HoH.add();
 end;
 
 maxCount=0;
 do Rows = 1 by 1 until(lr);
    set dw.AtBats end=lr;
    do I = 1 to dim(_Variables);
       HoH.find();
       if missing(_Variables(i)) then continue;
       if h.find() ne 0 then Count = 0;
       Count + 1;
       h.replace();
       Total + 1;
       Sum + _Variables(I);
       maxCount = max(Count,maxCount);
       HoH.replace();
    end;
 end;
 do I = 1 to dim(_Variables);
    _cum = 0;
    HoH.find();
    iter_ptiles.first();
    last = .;
    do j = 1 to h.num_items;
       iter.next();
       Percent = divide(Count,Total);
       _Cum + Count;
       Cumulative = _Cum;
       Cum_Percent = divide(_Cum,Total);
       Value = _Variables(I); /*vvalue(_Variables(I))*/
       output;
       if Count = maxCount
          then results.add(Key:Variable
                          ,Key:"Mode"
                          ,Data:Variable
                          ,Data:"Mode"
                          ,Data:_Variables(I) /*vvalue(_Variables(I))*/
                          );
       if last le Percentile le Cum_Percent then
       do;  /* found the percentile */
          if percentile ne 1 then results.add();
          if iter_ptiles.next() ne 0 then percentile = 1;
       end; /* found the percentile */
       last = Cum_Percent;
    end;
    Value = divide(Sum,Total);
    Metric = "Mean";
    results.add();
    iter.first();
    Value = _Variables(I); /*vvalue(_Variables(I))*/
    Metric = "Min";
    results.add();
    iter.last();
    Value = _Variables(I); /*vvalue(_Variables(I))*/
    Metric = "Max";
    results.add();
 end;
 results.output(dataset:"Metrics");
 stop;
 set ptiles;
run;