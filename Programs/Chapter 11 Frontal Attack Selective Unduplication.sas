/* "Chapter 11 Frontal Attack Selective Unduplication.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  dcl hash h (ordered:"A") ; *Output in Home_SK order;
  h.defineKey  ("Home_SK") ;
  h.defineData ("Home_SK", "Away_SK", "Date", "Game_SK") ;
  h.defineDone () ;
  do until (lr) ;
    set dw.games (keep = Game_SK Date Home_SK Away_SK) end = lr ;
    _Away_SK = Away_SK ;
    _Date    = Date ;
    _Game_SK = Game_SK ;
    if h.find() ne 0 then h.add() ;
    else if _Date > Date then
      h.replace (key:Home_SK, data:Home_SK, data:_Away_SK, data:_Date
                            , data:_Game_SK
                 ) ;
  end ;
  h.output (dataset: "Last_games_hash") ;
  stop ;
run ;
