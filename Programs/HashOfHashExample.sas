/**
  @file
  @brief Example of hash of hash
  @author Paul M. Dorfman and Don Henderson
**/

data tables;
 informat Table Key $32.;
 input Table Key KeyAsData;
 datalines;
 Overall _N_       0
 Team    Team_SK   1
 Batter  Batter_ID 1
run;

data _null_ ;

   dcl hash players(dataset:'bizarro.players') ;
   players.defineKey('Player_ID') ;
   players.defineData('Team_SK','Last_Name','First_Name') ;
   players.defineDone() ;

   dcl hash hoh() ;
   hoh.defineKey ('Table') ;
   hoh.defineData('H','Table') ;
   hoh.defineDone() ;
   dcl hiter i_hoh('hoh') ;
   dcl hash h() ;

   do until(lr) ;
      do q = 1 by 1 until (last.Table) ;
         set tables end = lr ;
         by Table notsorted ;
         if q = 1 then h = _new_ hash (ordered:'a') ;
         h.defineKey(Key) ;
         if KeyAsData = 1 then h.defineData(Key) ;
      end  ;
      h.defineData('ABs') ;
      h.defineData('Hits') ;
      h.defineData('BA') ; 
      h.defineDone() ;
      hoh.add() ;
   end ;
        
   format BA 4.3;

   do lr = 0 by 0 until (lr) ;
      set bizarro.atbats end = lr ;
      _iorc_ = players.find(key:batter_id);
      do until (i_hoh.next()) ;
         if h.find() ne 0 then call missing (ABs, Hits, BA) ;
         ABs + Is_An_AB;
         Hits + Is_A_Hit;
         BA = Divide(Hits,ABs); 
         h.replace() ;
      end ;
   end ;

   do while (i_hoh.next() = 0) ;
       h.output(dataset:Table) ;
   end ;
   stop ;
   set bizarro.atbats
       bizarro.players
   ;
run ;
