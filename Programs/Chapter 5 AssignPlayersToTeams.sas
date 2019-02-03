/* "Chapter 5 AssignPlayersToTeams.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data positions;
 set bizarro.positions;
 retain DummyKey 1;
 drop position;
run;
 
data _null_;
 
 if 0 then set template.player_candidates;
 retain Player_ID 10000 Start_Date "01MAR2017"d End_Date &SCD_End_Date;
 format Player_ID z5. Start_Date End_Date mmddyy10.;
 informat Start_Date End_Date yymmdd10.;
 
 /* load the available players */
 declare hash available(dataset:"bizarro.player_candidates",multidata:"yes");
 rc = available.defineKey("Position_Code");
 rc = available.defineData("Player_ID","Team_SK","First_Name","Last_Name"
                          ,"Position_Code","Bats","Throws");
 rc = available.defineDone();
 
 /* load the hash table of positions */
 declare hash positions(dataset:"positions",multidata:"yes");
 rc = positions.defineKey("DummyKey");
 rc = positions.defineData("Position_Code","Count");
 rc = positions.defineDone();
 
 /* load the list of teams */
 declare hash teams(dataset:"Bizarro.teams");
 rc = teams.defineKey("Team_SK");
 rc = teams.defineDone();
 declare hiter teams_iter("teams");
 
 DummyKey = 1;
 pos_rc = positions.find();
 avail_rc = available.find();
 do until(pos_rc);
    teams_rc = teams_iter.first();
    do until(teams_rc);
       Team = Team_SK;
       do i = 1 to Count;
          Team_SK = Team;
          available.replaceDup();
          avail_rc = available.find_next();
       end;
       teams_rc = teams_iter.next();
    end;
    pos_rc = positions.find_next();
    avail_rc = available.find();
 end;
 rc = available.output(dataset:"bizarro.player_candidates");
run;
  
data bizarro.trades;
 format trade_date yymmdd10.;
 input trade_date yymmdd10. traded_id _position_code $3. _team_sk traded_to;
datalines;
2017/06/23 10090 SP  269 115
2017/06/23 10753 SP  115 269
2017/07/26 10103 COF 171 228
2017/07/26 10760 COF 228 171
2017/08/30 10145 CF  193 130
2017/08/30 10732 CF  130 193
;
 
