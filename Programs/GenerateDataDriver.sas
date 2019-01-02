/**
  @file
  @brief Driver program which calls the programs in order to generate the data
  @author Paul M. Dorfman and Don Henderson
**/

options nomprint nosource2;  /* turn on/off as needed */

%inc "&root/Programs/S0100-GenerateTeams.sas";

%inc "&root/Programs/S0200-GeneratePositionsDimensionTable.sas";

%inc "&root/Programs/s0300-GeneratePlayerCandidates.sas";

%inc "&root/Programs/S0400-AssignPlayersToTeams.sas";

%inc "&root/Programs/S0500-GenerateMatchUpCombinations.sas";

%inc "&root/Programs/S0600-GenerateSchedule.sas";

%generateLineUps(from=&seasonStartDate,to=&seasonEndDate)

%inc "&root/Programs/S0800-GeneratePitchDistribution.sas";

%generatePitchAndPAData(from=&seasonStartDate,to=&seasonEndDate)
