/**
  @file
  @brief Environment Setup (if not using bizarro.sas)
  @author Paul M. Dorfman and Don Henderson
**/

%let root = C:\HCS\Projects\HashBook\BizarroBall;
libname bizarro "&root\Data";
options insert=(sasautos=("&root\Macros"))
        source2
;

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
