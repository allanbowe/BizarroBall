/* "Chapter 6 Sample from AtBats.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Sample (keep = Batter_ID Result Sequence) ;
  set bizarro.AtBats ;
  where Team_SK = 193 and Position_code = "SP" and Top_Bot = "B"
  and   date between "20mar2017"d and "09apr2017"d
  and   Result in ("Single", "Double") ;
  Sequence + 1 ;
run ;
