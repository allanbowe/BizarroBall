/* "Chapter 11 Hash Entry Size Test.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_ ;
  array KN [20] (20 * 1) ;
  dcl hash h() ;
  do i = 1 to dim (KN) ;
    h.defineKey (vname(KN[i])) ;
  end ;
  h.defineData ("KN1") ;
  h.definedone() ;
  Hash_Entry_Size = h.item_size ;
  put Hash_Entry_Size= ;
  do KN1 = 1 to 1E6 ;
    h.add() ;
  end ;
run ;
