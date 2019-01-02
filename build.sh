#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error

BBFILE="./bizarroball.sas"

cat > $BBFILE <<'EOL'
/**
  @file
  @brief Auto-generated file
  @details The `build.sh` file in the https://github.com/allanbowe/bizarro repo
    is used to create this file.
  @author Allan Bowe (derivative of work by Don Henderson and Paul Dorfman)
  ///@cond INTERNAL
**/

/* Create data source (change root to a permanent location) */
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

/* now include macros & datalines */
EOL

cat Macros/* >> $BBFILE

cat "Programs/S0100-GenerateTeams.sas" >> $BBFILE

cat "Programs/S0200-GeneratePositionsDimensionTable.sas" >> $BBFILE

cat "Programs/s0300-GeneratePlayerCandidates.sas" >> $BBFILE

cat "Programs/S0400-AssignPlayersToTeams.sas" >> $BBFILE

cat "Programs/S0500-GenerateMatchUpCombinations.sas" >> $BBFILE

cat "Programs/S0600-GenerateSchedule.sas" >> $BBFILE

echo "%generateLineUps(from=&seasonStartDate,to=&seasonEndDate)" >> $BBFILE

cat "Programs/S0800-GeneratePitchDistribution.sas"  >> $BBFILE

echo "%generatePitchAndPAData(from=&seasonStartDate,to=&seasonEndDate)" >> $BBFILE

echo "/* ///@endcond */" >> $BBFILE

# for mac, use brew install unix2dos
unix2dos $BBFILE