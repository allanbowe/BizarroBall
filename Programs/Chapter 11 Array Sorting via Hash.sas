/* "Chapter 11 Array Sorting via Hash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%let order = A ; * Sort: A/D (Ascending/Descending ;
%let dupes = N ; * Dups: Y/N (Yes/No) ;
%let which = L ; * Dupe to select: F/L (First/Last) ;
 
data _null_ ;
  array kN [9]    ( 7   7   7   7   5   5   5   3   3 ) ;
  array kC [9] $1 ('F' 'E' 'F' 'E' 'D' 'C' 'D' 'A' 'B') ;
  array dN [9]    ( 8   6   9   7   4   3   5   1   2 ) ;
  if _n_ = 1 then do ;
    dcl hash h (multidata:"Y", ordered:"&order") ;
    h.defineKey  ("_kN", "_kC") ;
    h.defineData ("_kN", "_kC", "_dN") ;
    h.defineDone () ;
    dcl hiter hi ("h") ;
  end ;
  do _j = 1 to dim (kN) ;
    _kN = kN[_j] ; _kC = kC[_j] ; _dN = dN[_j] ;
    if      "&dupes" = "Y" then h.add() ;
    else if "&which" = "F" then h.ref() ;
    else                        h.replace() ;
  end ;
  call missing (of kN[*], of kC[*], of dN[*]) ;
  do _j = 1 by 1 while (hi.next() = 0) ;
    kN[_j] = _kN ; kC[_j] = _kC ; dN[_j] = _dN ;
  end ;
  h.clear() ;
  put "kN: " kN[*] / "kC: " kC[*] / "dN: " dN[*] ;
run ;
