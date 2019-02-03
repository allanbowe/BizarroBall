/* "Chapter 6 Sample from Games.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Sample_games (keep = Date Home_SK Away_SK) ;
  set bizarro.Games ;
  where League = 1 and DayOfWeek = 1 ;
run ;
