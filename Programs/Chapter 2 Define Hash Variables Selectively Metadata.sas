/* "Chapter 2 Define Hash Variables Selectively Metadata.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H() ;
  do until (lr) ;
    set sashelp.vcolumn (keep=memname libname Name) end=lr ;
    where libname="BIZARRO" and memname="PLAYER_CANDIDATES" ;
    isKey = scan (upcase (Name), -1, "_") in ("ID","SK") ;
    if isKey then H.defineKey(Name) ;
    else H.defineData(Name) ;
  end ;
  H.defineDone () ;
  stop ;
  set bizarro.Player_candidates ;
run ;
