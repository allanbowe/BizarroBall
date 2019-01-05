/**
  @file
  @brief Environment Setup 
  @details This step is only relevant if you are configuring your setup to load the source files from disk (as per the original intention when the project was released).  The idea is that this program will be run first, before all the other programs, so that changes to settings (macro variables) will be applied.
  This is superceded now by the single bizarroball.sas file, as created in the build.sh script.

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
