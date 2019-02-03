/* "Chapter 8 Slash Line.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 dcl hash slashline(ordered:"A");
 slashline.defineKey("Batter_ID");
 slashline.defineData("Batter_ID","PAs","AtBats","Hits","_Bases","_Reached_Base"
                     ,"BA","OBP","SLG","OPS");
 slashline.defineDone();
 format BA OBP SLG OPS 5.3;
 do until(lr);
    set dw.AtBats end = lr;
    call missing(PAs,AtBats,Hits,_Bases,_Reached_Base);
    rc = slashline.find();
    PAs           + 1;
    AtBats        + Is_An_AB;
    Hits          + Is_A_Hit;
    _Bases        + Bases;
    _Reached_Base + Is_An_OnBase;
    BA = divide(Hits,AtBats);
    OBP = divide(_Reached_Base,PAs);
    SLG = divide(_Bases,AtBats);
    OPS = sum(OBP,SLG);
    slashline.replace();
 end;
 slashline.output(dataset:"Batter_Slash_Line(drop=_:)");
run;