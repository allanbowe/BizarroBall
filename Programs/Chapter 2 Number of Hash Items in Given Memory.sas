/* "Chapter 2 Number of Hash Items in Given Memory.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash H () ;
  H.defineKey ("Player_ID", "Team_SK") ;
  H.defineData ("First_name", "Last_name", "Position_code") ;
  H.definedone () ;
  Entry_length = H.item_size ;
  N_items_in_1GB = round (2**30 / Entry_length) ;
  put (Entry_length N_items_in_1GB) (=comma16./) ;
  stop ;
  set bizarro.Player_candidates ;
run ;
