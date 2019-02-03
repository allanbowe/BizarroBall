/* "importData.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study

    This program is used to create the three data libraries used in the book.
    SAS transport format files are used in order to support Window, Unix,
    and Linux (which includes the SAS University Edition).
*/

proc cimport lib = bizarro file = "&root/bizarro.xpt";
run;

proc cimport lib = template file = "&root/template.xpt";
run;

proc cimport lib = dw file = "&root/dw.xpt";
run;
