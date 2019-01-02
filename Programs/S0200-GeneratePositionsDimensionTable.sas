/**
  @file
  @brief  Loads data on the distribution of how many players to assign to each 
    team (e.g., how many infielders, outfielders, starting pitchers, etc)
  @author Paul M. Dorfman and Don Henderson
**/

data bizarro.Positions_Dim;
 input Position_Code $2. +1 Position $16. +1 Count 8.;
 datalines;
SP Starting Pitcher 5
RP Relief Pitcher   5
C  Catcher          3
IF Infielder        4
OF Outfielder       3
UT Utility          2
;
