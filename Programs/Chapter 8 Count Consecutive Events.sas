/* "Chapter 8 Count Consecutive Events.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Consecutive_Hits;
 keep Consecutive_Hits Exact_Count Total_Count;
 format Consecutive_Hits 8.
        Exact_Count Total_Count comma10.;
 retain Exact_Count 1;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash consecHits(ordered:"D",suminc:"Exact_Count");
    consecHits.defineKey("Consecutive_Hits");
    consecHits.defineDone();
 end; /* define the hash table */
 Consecutive_Hits = 0;
 do until(last.Top_Bot);
    set dw.atbats(keep=Game_SK Inning Top_Bot Is_A_Hit) end=lr;
    by Game_SK Inning Top_Bot notsorted;
    Consecutive_Hits = ifn(Is_A_Hit,Consecutive_Hits+1,0);
    if Is_A_Hit then consecHits.ref();
 end;
 if lr;
 Total_Adjust = 0;
 do Consecutive_Hits = consecHits.num_items to 1 by -1;
    consecHits.sum(sum:Exact_Count);
    Total_Count = Exact_Count + Total_Adjust;
    output;
    Total_Adjust + Exact_Count;
 end;
run;