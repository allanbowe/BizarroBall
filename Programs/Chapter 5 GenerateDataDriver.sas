/* "Chapter 5 GenerateDataDriver.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

options nomprint nosource;  /* turn on/off as needed */
 
%inc "&root/Programs/Chapter 5 GenerateTeams.sas";
 
%inc "&root/Programs/Chapter 5 GeneratePositionsDimensionTable.sas";
 
%inc "&root/Programs/Chapter 5 GeneratePlayerCandidates.sas";
 
%inc "&root/Programs/Chapter 5 AssignPlayersToTeams.sas";
 
%inc "&root/Programs/Chapter 5 GenerateSchedule.sas";
 
%inc "&root/Programs/Chapter 5 GeneratePitchDistribution.sas";
 
%generateLineUps(from=&seasonStartDate,nWeeks=&nWeeksSeason)
 
%generatePitchAndPAData(from=&seasonStartDate,nWeeks=&nWeeksSeason)
