/* "Chapter 11 Hash Vs SAS Index Access Speed.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Pitches (index=(RID) keep=RID Pitcher_ID Result) ;
  set dw.Pitches ;
  RID = _N_ ;
run ;
 
%let test_reps = 10 ;
 
data _null_ ;
  dcl hash h (dataset: "Pitches", hashexp:20) ;
  h.definekey  ("RID") ;
  h.defineData ("Pitcher_ID") ;
  h.defineDone () ;
  time = time() ;
  do Rep = 1 to &test_reps ;
    do RID = 1 to N * 2 ;
      rc = h.find() ;
    end ;
  end ;
  Hash_time = time() - time ;
  time = time() ;
  do Rep = 1 to &test_reps ;
    do RID = 1 to N * 2 ;
      set Pitches key=RID nobs=N ;
    end ;
  end ;
  _error_ = 0 ; * prevent log error notes ;
  Indx_time = time() - time ;
  put "Hash_time =" Hash_time 6.2-R
    / "Indx_time =" Indx_time 6.2-R ;
  stop ;
run ;
