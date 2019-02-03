/* "Chapter 8 MeanMedianMode.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let Var = Distance;
 
data ptiles;
 input Ptile;
 Metric = put(Ptile,percent6.);
 retain Value . ;
 datalines;
 .05
 .1
 .25
 .5
 .75
 .95
;
 
data _null_;
 
 format Percent Cum_Percent percent7.2;
 
 dcl hash metrics(dataset:"ptiles"
                 ,multidata:"Y"
                 ,ordered:"A");
 metrics.defineKey("Ptile");
 metrics.defineData("Ptile","Metric","Value");
 metrics.defineDone();
 dcl hiter iterPtiles("metrics");
 
 dcl hash distribution(ordered:"A");
 distribution.defineKey("&Var");
 distribution.defineData("&Var","Count","Percent","Cumulative","Cum_Percent");
 distribution.defineDone();
 dcl hiter iterDist("distribution");
 do Rows = 1 by 1 until(lr);
    set dw.AtBats(keep=&Var) end=lr;
    where &Var gt .;
    if distribution.find() ne 0 then Count = 0;
    Count + 1;
    distribution.replace();
    Total + &Var;
    maxCount = max(Count,maxCount);
 end;
 
 iterPtiles.first();
 last = .;
 do i = 1 to distribution.num_items;
    iterDist.next();
    Percent = divide(Count,Rows);
    _Cum + Count;
    Cumulative = _Cum;
    Cum_Percent = divide(_Cum,Rows);
    distribution.replace();
    if Count = maxCount then metrics.add(Key:.,Data:. ,Data:"Mode",Data:&Var);
    if last le ptile le Cum_Percent then
    do;  /* found the percentile */
       Value = &Var;
       if ptile ne 1 then metrics.replace();
       if iterPtiles.next() ne 0 then ptile = 1;
    end; /* found the percentile */
    last = Cum_Percent;
 end;
 
 metrics.add(Key:.,Data:.,Data:"Mean",Data:divide(Total,Rows));
 
 iterDist.first();
 metrics.add(Key:.,Data:.,Data:"Min",Data:&Var);
 
 iterDist.last();
 metrics.add(Key:.,Data:.,Data:"Max",Data:&Var);
 
 metrics.output(dataset:"Metrics(drop=ptile)");
 distribution.output(dataset:"Distribution");
 
 stop;
 set ptiles;
run;