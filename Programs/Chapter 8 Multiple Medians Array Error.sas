/* "Chapter 8 Multiple Medians Array Error.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data _null_;
 dcl hash single(dataset:"dw.AtBats(where=(Result='Single'))"
                ,multidata:"Y"
                ,ordered:"A");
 single.defineKey("Distance");
 single.defineDone();
 dcl hiter singleIter("single");
 dcl hash double(dataset:"dw.AtBats(where=(Result='Double'))"
                ,multidata:"Y",ordered:"A");
 double.defineKey("Distance");
 double.defineDone();
 dcl hiter doubleIter("double");
 
 dcl hash triple(dataset:"dw.AtBats(where=(Result='Triple'))"
                ,multidata:"Y"
                ,ordered:"A");
 triple.defineKey("Distance");
 triple.defineDone();
 dcl hiter tripleIter("triple");
 dcl hash homerun(dataset:"dw.AtBats(where=(Result='Home Run'))"
                 ,multidata:"Y"
                 ,ordered:"A");
 homerun.defineKey("Distance");
 homerun.defineDone();
 homerun.output(dataset:'h');
 dcl hiter homerunIter("homerun");
 array _hashes(*) single double triple homerun;
 array _iters(*) singleIter doubleIter tripleIter homerunIter;
 stop;
run;
