/* "Chapter 10 Implementing a Hash Stack.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Demo_Stack (keep = Action PDV_Data Items) ;
  dcl hash h (ordered:"A") ;
  h.defineKey  ("Key") ;
  h.defineData ("Key", "Data") ;
  h.definedone () ;
  dcl hiter ih ("h") ;
  Data = "A" ; link Push ;
  Data = "B" ; link Push ;
  Data = "C" ; link Push ;
               link Pop ;
  Data = "D" ; link Push ;
  Data = "E" ; link Push ;
               link Pop ;
               link Pop ;
  stop ;
  Push: Key = h.num_items + 1 ;
        h.add() ;
        Action = "Push" ;
        link List ;
  return ;
  Pop:  ih.last() ;
        rc = ih.next() ;
        h.remove() ;
        Action = "Pop" ;
        link List ;
  return ;
  List: PDV_Data  = Data ;
        Items = put ("", $64.) ;
        do while (ih.next() = 0) ;
          Items = catx (" ", Items, cats ("[", Key, ",", Data, "]"));
        end ;
        output ;
  return ;
run ;
