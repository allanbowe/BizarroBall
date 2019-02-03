/*
  @file
  @brief maps the libraries.  Assumes that `bizarroball.sas` was 
    already executed (to load the data)
  @author Allan Bowe (derivative of work by Don Henderson and Paul Dorfman)
*/

%let root=%sysfunc(pathname(sasuser)); /* change to another path as desired */
%*let root = /folders/myfolders/BizarroBall; /* use this for the University Edition */

libname bizarro "&root/Data";
libname DW "&root/DW";
libname template "&root/Data/Template";