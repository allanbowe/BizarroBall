/* "Chapter 9 HoH Count Consecutive Events.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 format Consecutive_Hits Consecutive_OnBase 8.
        Hits_Exact_Count Hits_Total_Count
        OnBase_Exact_Count OnBase_Total_Count comma10.;
 array _Is_A(*) Is_A_Hit Is_An_OnBase;
 array _Consecutive(*) Consecutive_Hits Consecutive_OnBase;
 array _Exact(*) Hits_Exact_Count OnBase_Exact_Count;
 array _Total(*) Hits_Total_Count OnBase_Total_Count;
 if _n_ = 1 then
 do;  /* define the hash tables */
     dcl hash HoH(ordered:"A");
     HoH.defineKey ("I");
     HoH.defineData ("H","ITER","Table");
     HoH.defineDone();
     dcl hash h();
     dcl hiter iter;
 
     h = _new_ hash(ordered:"D");
     h.defineKey("Consecutive_Hits");
     h.defineData("Consecutive_Hits","Hits_Total_Count","Hits_Exact_Count");
     h.defineDone();
     iter = _new_ hiter("H");
     I = 1;
     Table = vname(_Consecutive(I));
     HoH.add();
 
     h = _new_ hash(ordered:"D");
     h.defineKey("Consecutive_OnBase");
     h.defineData("Consecutive_OnBase","OnBase_Total_Count"
                 ,"OnBase_Exact_Count");
     h.defineDone();
     iter = _new_ hiter("H");
     I = 2;
     Table = vname(_Consecutive(I));
     HoH.add();;
 end; /* define the hash table */
 do I = 1 to dim(_Consecutive);
    _Consecutive(I) = 0;
 end;
 do until(last.Top_Bot);
    set dw.atbats(keep=Game_SK Inning Top_Bot Is_A_Hit Is_An_OnBase) end=lr;
    by Game_SK Inning Top_Bot notsorted;
    do I = 1 to dim(_Consecutive);
       _Consecutive(I)=ifn(_Is_A(I),_Consecutive(I)+1,0);
    end;
    do I = 1 to HoH.num_items;
       HoH.find();
       if h.find() ne 0 then call missing(_Exact(I));
       _Exact(I) + 1;
       if _Is_A(I) then h.replace();
    end;
 end;
 if lr;
 do I = 1 to dim(_Consecutive);
    HoH.find();
    Cum = 0;
    do consec = 1 to h.num_items;
       rc = iter.next();
       Cum + _Exact(I);
       _Total(I) = Cum;
       h.replace();
    end;
    h.output(dataset:Table);
 end;
run;
