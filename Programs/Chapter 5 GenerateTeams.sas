/* "Chapter 5 GenerateTeams.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data bizarro.teams;
 /* Select team names from 100 most popular team names.
    Source: http://mascotdb.com/lists.php?id=5
 */
 keep League_SK Team_SK Team_Name;
 keep League; /* fix for rename issue found post-publication */ 
 label League_SK = "League Surrogate Key"
       Team_SK = "Team Surrogate Key"
       Team_Name = "Team Name"
 ;
 retain League_SK . Team_SK 100;
 if _n_ = 1 then
 do;  /* create hash table */
    declare hash teams();
    rc = teams.defineKey("Team_Name");
    rc = teams.defineData("Team_SK","Team_Name");
    rc = teams.defineDone();
 end; /* create hash table */
 infile datalines eof=lr;
 input Team_Name $16.;
 Team_SK + ceil(uniform(&seed1)*4);
 rc = teams.add();
 return;
 lr:
 declare hiter teamIter("teams");
 do i = 1 to 2*&nTeamsPerLeague;
    rc = teamIter.next();
    League_SK = int((i-1)/&nTeamsPerLeague) + 1;
    League = League_SK;  /* fix for rename issue found post-publication */
    output;
 end;
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
;
data bizarro.leagues;
 label League_SK = "League Surrogate Key"
       League = "League"
 ;
 League_SK = 1;
 League = 'Eastern';
 output;
 League_SK = 2;
 League = 'Western';
 output;
run;
