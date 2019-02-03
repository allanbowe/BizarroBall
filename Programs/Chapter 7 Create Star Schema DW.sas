/* "Chapter 7 Create Star Schema DW.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc datasets lib = dw nolist;
 options obs = 0;
 copy in=bizarro out=dw;
 select AtBats
        Pitches
        Runs
        Games;
 copy in=template out=dw;
 select Players_Positions_Played Players;
run;
 options obs = max;
 copy in=bizarro out=dw;
 select Leagues
        Teams;
quit;

/* The following step added post-publication to address the issue with
   an earlier rename of League to League_SK.
*/
proc sql;
 alter table dw.teams
   drop league;
quit;
