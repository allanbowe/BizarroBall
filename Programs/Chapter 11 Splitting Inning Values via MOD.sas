/* "Chapter 11 Splitting Inning Values via MOD.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let N_groups = 3 ;
 
data Groups ;
  do Inning = 1 to 9 ;
    Group     = 1 + mod (Inning, &N_groups) ;
    Group_Seq = 1 + mod (Inning + &N_groups - 1
                        ,&N_groups) ;
    output ;
  end ;
run ;
