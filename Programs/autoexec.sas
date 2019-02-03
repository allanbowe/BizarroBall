/* "autoexec.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let root = /BizarroBall;
%*let root = /folders/myfolders/BizarroBall; /* use this for the University Edition */
libname bizarro "&root/Data";
libname DW "&root/DW";
libname template "&root/Data/Template";
options insert=(sasautos=("&root/Macros"))
        source2
;
 
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
