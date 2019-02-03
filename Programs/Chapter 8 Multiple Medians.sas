/* "Chapter 8 Multiple Medians.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data Medians;
 length Type $12;
 keep Type Distance Count;
 format Count comma9.;
 
 dcl hash h();
 h = _new_ hash(dataset:"dw.AtBats(where=(Result='Single'))"
               ,multidata:"Y",ordered:"A");
 h.defineKey("Distance");
 h.defineDone();
 type = "Singles";
 dcl hiter iter;
 iter = _new_ hiter("h");
 link getMedians;
 
 h = _new_ hash(dataset:"dw.AtBats (where=(Result='Double'))"
               ,multidata:"Y",ordered:"A");
 h.defineKey("Distance");
 h.defineDone();
 type = "Doubles";
 iter = _new_ hiter("h");
 link getMedians;
 
 h = _new_ hash(dataset:"dw.AtBats(where=(Result='Triple'))"
               ,multidata:"Y",ordered:"A");
 h.defineKey("Distance");
 h.defineDone();
 type = "Triples";
 iter = _new_ hiter("h");
 link getMedians;
 
 h = _new_ hash(dataset:"dw.AtBats(where=(Result='Home Run'))"
               ,multidata:"Y",ordered:"A");
 h.defineKey("Distance");
 h.defineDone();
 type = "Home Runs";
 iter = _new_ hiter("h");
 link getMedians;
 
 stop;
 getMedians:
    Count = h.num_items;
    iter.first();
    do i = 1 to .5*Count - 1;
      iter.next();
    end;
    /* could add logic here to interpolate if needed */
    output;
    h.delete();
 return;
 
 set dw.AtBats(keep=Distance);
run;