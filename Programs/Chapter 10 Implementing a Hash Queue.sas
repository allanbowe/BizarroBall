/* "Chapter 10 Implementing a Hash Queue.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Demo_Queue (keep = Action PDV_Data Items) ;
  dcl hash h (ordered:"A") ;
  h.defineKey  ("Key") ;
  h.defineData ("Key", "Data") ;
  h.definedone () ;
  dcl hiter ih ("h") ;
  Data = "A" ; link Queue ;
  Data = "B" ; link Queue ;
  Data = "C" ; link Queue ;
               link DeQueue ;
  Data = "D" ; link Queue ;
  Data = "E" ; link Queue ;
               link DeQueue ;
               link DeQueue ;
  stop ;
  Queue: Key + 1 ;
         h.add() ;
         Action = "Queue  " ;
         link List ;
  return ;
  DeQueue: ih.first() ;
           rc = ih.prev() ;
           h.remove() ;
           Action = "DeQueue" ;
           link List ;
  return ;
  List: PDV_Data  = Data ;
        Items = put ("", $64.) ;
        do while (ih.next() = 0) ;
          Items = catx ("  ", Items, cats ("[", Key, ",", Data, "]")) ;
        end ;
        output ;
  return ;
run ;
