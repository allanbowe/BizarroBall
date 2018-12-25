%let root = %sysfunc(pathname(work));

options dlcreatedir;
libname bizarro "&root/Data";


/* Parameters for creating the data */
%let nTeamsPerLeague = 16;
%let seasonStartDate = 01MAR2017;
%let seasonEndDate = 31MAR2017;
%let nPlayersPerTeam = 50;
%let nBattersPerGame = 14;
%let springTrainingFactor = 2;

/* Random Number Seeds */
%let seed1 = 54321;
%let seed2 = 98765;
%let seed3 = 76543;
%let seed4 = 11;
%let seed5 = 9887;
%let seed6 = 9973;
%let seed7 = 101;


/* %inc "&root/Programs/S0100-GenerateTeams.sas"; */

data bizarro.teams;
 /* Select team names from 100 most popular team names.
    Source: http://mascotdb.com/lists.php?id=5
 */
 keep League Team_SK Team_Name;
 retain League . Team_SK 100;
 if _n_ = 1 then
 do;  /* create hash table */
    declare hash teams();
    rc = teams.defineKey('Team_Name');
    rc = teams.defineData('Team_SK','Team_Name');
    rc = teams.defineDone();
 end; /* create hash table */
 infile datalines eof=lr;
 input Team_Name $16.;
 Team_SK + ceil(uniform(&seed1)*4);
 rc = teams.add();
 return;
 lr:
 declare hiter teamIter('teams');
 do i = 1 to 2*&nTeamsPerLeague;
    rc = teamIter.next();
    League = int((i-1)/16) + 1;
	output;
 end;
 *rc = teams.output(dataset:'showOrder');
datalines;
Eagles
Tigers
Bulldogs
Panthers
Wildcats
Warriors
Lions
Indians
Cougars
Knights
Mustangs
Falcons
Trojans
Cardinals
Vikings
Pirates
Raiders
Rams
Spartans
Bears
Hornets
Patriots
Hawks
Crusaders
Rebels
Bobcats
Saints
Braves
Blue Devils
Titans
Wolverines
Jaguars
Wolves
Dragons
Pioneers
Chargers
Rockets
Huskies
Red Devils
Yellowjackets
Chiefs
Stars
Comets
Colts
Lancers
Rangers
Broncos
Giants
Senators
Bearcats
Thunder
Royals
Storm
Cowboys
Cubs
Cavaliers
Golden Eagles
Generals
Owls
Buccaneers
Hurricanes
Bruins
Grizzlies
Gators
Bombers
Red Raiders
Flyers
Lakers
Miners
Redskins
Coyotes
Longhorns
Greyhounds
Beavers
Yellow Jackets
Outlaws
Reds
Highlanders
Sharks
Oilers
Jets
Dodgers
Mountaineers
Red Sox
Thunderbirds
Blazers
Clippers
Aces
Buffaloes
Lightning
Bluejays
Gladiators
Mavericks
Monarchs
Tornadoes
Blues
Cobras
Bulls
Express
Stallions
;;



/*


%inc "&root/Programs/S0200-GeneratePositionsDimensionTable.sas";

%inc "&root/Programs/s0300-GeneratePlayerCandidates.sas";

%inc "&root/Programs/S0400-AssignPlayersToTeams.sas";

%inc "&root/Programs/S0500-GenerateMatchUpCombinations.sas";

%inc "&root/Programs/S0600-GenerateSchedule.sas";

%generateLineUps(from=&seasonStartDate,to=&seasonEndDate)

%inc "&root/Programs/S0800-GeneratePitchDistribution.sas";

%generatePitchAndPAData(from=&seasonStartDate,to=&seasonEndDate)