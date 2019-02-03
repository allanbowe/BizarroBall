/* "Chapter 8 Mode.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Modes;
 keep Distance Count;
 format Distance Count comma5.;
 dcl hash mode();
 mode.defineKey("Distance");
 mode.defineData("Distance","Count");
 mode.defineDone();
 dcl hiter iterM("mode");
 do until(lr);
    set dw.AtBats(keep=Distance) end=lr;
    where Distance gt .;
    if mode.find() ne 0 then Count = 0;
    Count + 1;
    mode.replace();
    maxCount = max(Count,maxCount);
 end;
 do i = 1 to mode.num_items;
    iterM.next();
    if Count = maxCount then output;
 end;
 stop;
run;