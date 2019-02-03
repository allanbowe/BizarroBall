/* "Chapter 10 Unduplication via Proc SORT.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sort nodupkey
  data   = dw.AtBats   (keep = Game_SK Batter_ID Result Top_Bot Inning)
  out    = nodup_sort (keep = Game_SK Batter_ID)
  dupout = dupes_sort (keep = Game_SK Batter_ID)
  ;
  where Batter_ID in (32390,51986,60088)
  and   Result  = "Triple"
  and   Top_Bot = "B"
  and   Inning  = 1
  ;
  by Batter_ID ;
run ;
