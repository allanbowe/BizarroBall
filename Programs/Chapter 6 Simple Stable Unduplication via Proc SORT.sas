/* "Chapter 6 Simple Stable Unduplication via Proc SORT.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

proc sort equals nodupkey
  data   = bizarro.atbats
  out    = nodup_sort (keep = Date Batter_ID Inning)
  dupout = dupes_sort (keep = Date Batter_ID Inning)
  ;
  where Team_SK = 193 and Result = "Triple" and Top_Bot = "B" ;
  by Batter_ID ;
run ;
