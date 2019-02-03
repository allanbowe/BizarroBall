/* "Chapter 6 Simple Subsetting via Hash Table.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Triple ;
  if _n_ = 1 then do ;
    dcl hash triple
   (dataset:'Dw.AtBats(rename=(Batter_ID=Player_ID)
                            where=(Result="Triple"))') ;
    triple.defineKey ("Player_ID") ;
    triple.defineData ("Player_ID") ;
    triple.defineDone () ;
  end ;
  set Bizarro.Player_candidates ;
  where Team_SK in (193) ;
  if triple.check() = 0 ;
* if not triple.check() = 0 ;
run ;
