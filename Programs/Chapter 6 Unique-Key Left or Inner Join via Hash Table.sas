/* "Chapter 6 Unique-Key Left or Inner Join via Hash Table.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Pitched ;
  if _n_ = 1 then do ;
    if 0 then set dw.Players_positions_played (keep=Player_ID Pitcher) ;
    dcl hash pitch (dataset: "dw.Players_positions_played (where=(Pitcher))") ;
    pitch.defineKey ("Player_ID") ;
    pitch.defineData ("Pitcher") ;
    pitch.defineDone () ;
  end ;
  set bizarro.Player_candidates ;
  where Team_SK in (193) ;
  call missing (Pitcher) ;
  _iorc_ = pitch.find() ; /*Left  join*/
* if _iorc_ ne 0 ;        /*Inner join*/
* if pitch.find() ne 0 ;  /*Inner join*/
run ;
