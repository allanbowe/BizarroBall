/* "Chapter 8 Count Multiple Different Consecutive Events.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Consecutive_Events;
 keep Consecutive_Events Hits_Exact_Count Hits_Total_Count
      OnBase_Exact_Count OnBase_Total_Count;
 format Consecutive_Events Hits_Exact_Count Hits_Total_Count
        OnBase_Exact_Count OnBase_Total_Count comma10.;
 retain Hits_Exact_Count OnBase_Exact_Count 1;
 if _n_ = 1 then
 do;  /* define the hash tables */
    dcl hash consecHits(ordered:"D",suminc:"Hits_Exact_Count");
    consecHits.defineKey("Consecutive_Hits");
    consecHits.defineDone();
    dcl hash consecOnBase(ordered:"D",suminc:"OnBase_Exact_Count");
    consecOnBase.defineKey("Consecutive_OnBase");
    consecOnBase.defineDone();
 end; /* define the hash tables */
 Consecutive_Hits = 0;
 Consecutive_OnBase = 0;
 do until(last.Top_Bot);
    set dw.atbats(keep=Game_SK Inning Top_Bot Is_A_Hit Is_An_OnBase) end=lr;
    by Game_SK Inning Top_Bot notsorted;
    Consecutive_Hits = ifn(Is_A_Hit,Consecutive_Hits+1,0);
    if Is_A_Hit then consecHits.ref();
    Consecutive_OnBase = ifn(Is_An_OnBase,Consecutive_OnBase+1,0);
    if Is_An_OnBase then consecOnBase.ref();
 end;
 if lr;
 Total_Adjust_Hits = 0;
 Total_Adjust_OnBase = 0;
 do Consecutive_Events = consecOnBase.num_items to 1 by -1;
    consecOnBase.sum(Key:Consecutive_Events,sum:OnBase_Exact_Count);
    rc = consecHits.sum(Key:Consecutive_Events,sum:Hits_Exact_Count);
    Hits_Total_Count = Hits_Exact_Count + Total_Adjust_Hits;
    OnBase_Total_Count = OnBase_Exact_Count + Total_Adjust_OnBase;
    output;
    Total_Adjust_Hits + Hits_Exact_Count;
    Total_Adjust_OnBase + OnBase_Exact_Count;
 end;
run;
 
data Consecutive_Events_Alternative;
 keep Consecutive_Events Hits_Exact_Count Hits_Total_Count
      OnBase_Exact_Count OnBase_Total_Count event;
 format Consecutive_Events 8. Hits_Exact_Count Hits_Total_Count
        OnBase_Exact_Count OnBase_Total_Count comma10.;
 length Event $6.;
 retain Hits_Total_Count OnBase_Total_Count 1;
 if _n_ = 1 then
 do;  /* define the hash table */
    dcl hash consecEvents(ordered:"D",suminc:"Total_Count");
    consecEvents.defineKey("Consecutive_Events","Event");
    consecEvents.defineDone();
    dcl hiter eventsIter("consecEvents");
 end; /* define the hash table */
 Consecutive_Hits = 0;
 Consecutive_OnBase = 0;
 do until(last.Top_Bot);
    set dw.atbats(keep=Game_SK Inning Top_Bot Is_A_Hit Is_An_OnBase) end=lr;
    by Game_SK Inning Top_Bot notsorted;
    Consecutive_Hits = ifn(Is_A_Hit,Consecutive_Hits+1,0);
    if Is_A_Hit then
    do;  /* update for Hits */
        Event = "Hits";
        Consecutive_Events = Consecutive_Hits;
        Total_Count = Hits_Total_Count;
        consecEvents.ref();
    end; /* update for Hits */
    Consecutive_OnBase = ifn(Is_An_OnBase,Consecutive_OnBase+1,0);
    if Is_An_OnBase then
    do;  /* update for OnBase */
        Event = "OnBase";
        Consecutive_Events = Consecutive_OnBase;
        Total_Count = OnBase_Total_Count;
        consecEvents.ref();
    end; /* update for OnBase */
 end;
 if lr;
 exact_adjust = 0;
 consecEvents.output(dataset:"Check");
 Prior = .;
 do i = consecEvents.num_items to 1 by -1;
    eventsIter.next();
    if Event = "OnBase" then
    do;
       consecEvents.sum(Key:consecutive_Events,Key:Event,sum:OnBase_Total_Count);
       OnBase_Exact_Count = OnBase_Total_Count - OnBase_exact_adjust;
       Onbase_exact_adjust + OnBase_Total_Count;
    end;
    else
    do;
       rc = consecEvents.sum(Key:consecutive_Events,Key:Event,sum:Hits_Total_Count);
       Hits_Exact_Count = Hits_Total_Count - Hits_exact_adjust;
       Hits_exact_adjust + Hits_Total_Count;
    end;
    if Prior ne consecutive_Events then
    do;
       output;
       Prior = consecutive_Events;
    end;
 end;
run;
