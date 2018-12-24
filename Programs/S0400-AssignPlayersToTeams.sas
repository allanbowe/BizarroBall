data positions_dim;
 set bizarro.positions_dim;
 retain DummyKey 1;
 drop position;
run;

data teams;
 set bizarro.teams(keep=team_sk);
 Assigned = 0;
run;

data _null_;
 
 if 0 then set positions_dim teams bizarro.player_candidates;
 retain Player_ID 10000;
 format Player_ID z5.;

 /* load the available players */
 declare hash available(dataset:"bizarro.player_candidates",multidata:"yes");
 rc = available.defineKey('Position_Code');
 rc = available.defineData('First_Name','Last_Name');
 rc = available.defineDone();

 /* load the hash table of positions */
 declare hash positions(dataset:"positions_dim",multidata:"yes");
 rc = positions.defineKey('DummyKey');
 rc = positions.defineData('Position_Code','Count');
 rc = positions.defineDone();

 /* load the list of teams */
 declare hash teams(dataset:'teams');
 rc = teams.defineKey('Team_SK');
 rc = teams.defineData('Team_SK','Assigned');
 rc = teams.defineDone();
 declare hiter teams_iter('teams');

 /* load the team data with slots for each position */
 declare hash players(ordered:'a');
 rc = players.defineKey('Player_ID');
 rc = players.defineData('Team_SK','Player_ID','First_Name','Last_Name','Position_Code');
 rc = players.defineDone();

 DummyKey = 1;
 pos_rc = positions.find();
 avail_rc = available.find();
 do until(pos_rc);
    teams_rc = teams_iter.first();
    do until(teams_rc);
       Needed = Count*2 + floor(uniform(&seed3)*2);
       do i = 1 to Needed;
          Player_ID + ceil(uniform(&seed4)*9);
          rc = players.add();
          avail_rc = available.find_next();
       end;
       Assigned = Assigned + Needed;
       rc = teams.replace();
       teams_rc = teams_iter.next();
    end;
    pos_rc = positions.find_next();
    avail_rc = available.find();
 end;
 /* Now add utility players to get each team to 50  players */
 Position_Code = 'UT';
 teams_rc = teams_iter.first();
 /* note that the hash iteration already pointing at the next available utility player
THIS MIGHT BE COINCIDENTAL?????
 */
 do until(teams_rc);
    do i = Assigned+1 to &nPlayersPerTeam;
       Player_ID + 1;
       avail_rc = available.find_next();
       rc = players.add();
    end;
    teams_rc = teams_iter.next();
 end;   
 rc = players.output(dataset:'bizarro.players');
run;

proc freq data = bizarro.players;
 title 'Quick Check of Position Distribution by Team';
 tables team_sk * position_code/norow nocol nopercent;
run;
