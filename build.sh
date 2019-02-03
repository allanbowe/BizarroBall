#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error

BBFILE="./bizarroball.sas"

cat > $BBFILE <<'EOL'
/**
  @file
  @brief Auto-generated file
  @details The `build.sh` file in the https://github.com/allanbowe/bizarroball repo
    is used to create this file.
  @author Allan Bowe (derivative of work by Don Henderson and Paul Dorfman)
  ///@cond INTERNAL
**/

%let defaultroot=%sysfunc(pathname(work)); /* change to permanent path, sasuser maybe */
%*let defaultroot = /folders/myfolders/BizarroBall; /* use this for the University Edition */

/* some conditional logic as root may have been predefined */
%global root; 
%let root=%sysfunc(coalescec(&root,&defaultroot));

options dlcreatedir;
libname bizarro "&root/Data";
libname DW "&root/DW";
libname template "&root/Data/Template";

/* SCD End Date - Used in Chapter 7 */
%let SCD_End_Date = '31DEC9999'd;

/* The following macro variables are only used in the programs/macros
   to generate the sample Bizarro Ball data.
*/

/* Parameters for creating the data */
%let nTeamsPerLeague = 16;
%let seasonStartDate = 20MAR2017;
%let nWeeksSeason = %eval((&nTeamsPerLeague-1)*2);
%let nPlayersPerTeam = 25;
%let nBattersPerGame = 9;
 
/* Random Number Seeds */
%let seed1  = 54321;  /* used in S0100 GenerateTeams.sas */
%let seed2  = 98765;  /* used in S0300 GeneratePlayerCandidates.sas */
%let seed3  = 76543;  /* used in S0300 GeneratePlayerCandidates.sas */
%let seed4  = 11;     /* used in S0500 GenerateSchedule.sas */
%let seed5  = 9887;   /* used in macro generatelinesups.sas */
%let seed6  = 9973;   /* used in macro generatepitchandpadata.sas */
%let seed7  = 101;    /* used in macro generatepitchandpadata.sas */
%let seed8  = 10663;  /* used in macro generatepitchandpadata.sas */
%let seed9  = 10753;  /* used in macro generatepitchandpadata.sas */
%let seed10 = 98999;  /* used in S0300 GeneratePlayerCandidates.sas */
%let seed11 = 99223;  /* used in S0300 GeneratePlayerCandidates.sas */


/* now include macros & datalines */
EOL

cat Macros/* >> $BBFILE

cat Programs/Templates/* >> $BBFILE

cat "Programs/Chapter 5 GenerateTeams.sas" >> $BBFILE

cat "Programs/Chapter 5 GeneratePositionsDimensionTable.sas" >> $BBFILE

cat "Programs/Chapter 5 GeneratePlayerCandidates.sas" >> $BBFILE

cat "Programs/Chapter 5 AssignPlayersToTeams.sas" >> $BBFILE

cat "Programs/Chapter 5 GenerateSchedule.sas" >> $BBFILE

cat "Programs/Chapter 5 GeneratePitchDistribution.sas" >> $BBFILE

echo "%generateLineUps(from=&seasonStartDate,nWeeks=&nWeeksSeason)" >> $BBFILE

echo "%generatePitchAndPAData(from=&seasonStartDate,nWeeks=&nWeeksSeason)" >> $BBFILE

cat "Programs/Chapter 7"* >> $BBFILE

echo "/* ///@endcond */" >> $BBFILE

# for mac, use brew install unix2dos
unix2dos $BBFILE