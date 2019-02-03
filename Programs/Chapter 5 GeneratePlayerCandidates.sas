/* "Chapter 5 GeneratePlayerCandidates.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data first_names;
 /* SRC: https://www.ssa.gov/oact/babynames/decades/century.html */
 infile datalines;
 informat First_Name $12.;
 input First_Name $;
 First_Name = propcase(First_Name);
 n + 1;
 datalines;
James
John
Robert
Michael
William
David
Richard
Joseph
Thomas
Charles
Christopher
Daniel
Matthew
Anthony
Donald
Mark
Paul
Steven
George
Kenneth
Andrew
Joshua
Edward
Brian
Kevin
Ronald
Timothy
Jason
Jeffrey
Ryan
Gary
Jacoby
Nicholas
Eric
Stephen
Jonathan
Larry
Scott
Frank
Justin
Brandon
Raymond
Gregory
Samuel
Benjamin
Patrick
Jack
Alexander
Dennis
Jerry
Tyler
Aaron
Henry
Douglas
Peter
Jose
Adam
Zachary
Walter
Nathan
Harold
Kyle
Carl
Arthur
Gerald
Roger
Keith
Jeremy
Lawrence
Terry
Sean
Albert
Joe
Christian
Austin
Willie
Jesse
Ethan
Billy
Bruce
Bryan
Ralph
Roy
Jordan
Eugene
Wayne
Louis
Dylan
Alan
Juan
Noah
Russell
Harry
Randy
Philip
Vincent
Gabriel
Bobby
Johnny
Howard
;
data last_names;
 /* SRC: http://names.mongabay.com/most_common_surnames.htm */
 infile datalines;
 informat Last_Name $12.;
 input Last_Name $;
 Last_Name = propcase(Last_Name);
 n + 1;
datalines;
SMITH
JOHNSON
WILLIAMS
JONES
BROWN
DAVIS
MILLER
WILSON
MOORE
TAYLOR
ANDERSON
THOMAS
JACKSON
WHITE
HARRIS
MARTIN
THOMPSON
GARCIA
MARTINEZ
ROBINSON
CLARK
RODRIGUEZ
LEWIS
LEE
WALKER
HALL
ALLEN
YOUNG
HERNANDEZ
KING
WRIGHT
LOPEZ
HILL
SCOTT
GREEN
ADAMS
BAKER
GONZALEZ
NELSON
CARTER
MITCHELL
PEREZ
ROBERTS
TURNER
PHILLIPS
CAMPBELL
PARKER
EVANS
EDWARDS
COLLINS
STEWART
SANCHEZ
MORRIS
ROGERS
REED
COOK
MORGAN
BELL
MURPHY
BAILEY
RIVERA
COOPER
RICHARDSON
COX
HOWARD
WARD
TORRES
PETERSON
GRAY
RAMIREZ
JAMES
WATSON
BROOKS
KELLY
SANDERS
PRICE
BENNETT
WOOD
BARNES
ROSS
HENDERSON
COLEMAN
JENKINS
PERRY
POWELL
LONG
PATTERSON
HUGHES
FLORES
WASHINGTON
BUTLER
SIMMONS
FOSTER
GONZALES
BRYANT
ALEXANDER
RUSSELL
GRIFFIN
DIAZ
HAYES
;
data _null_;
 if 0 then set template.player_candidates;
 retain Player_ID 10000 Team_SK 0;
 declare hash positionsDist();
 rc = positionsDist.defineKey("Index");
 rc = positionsDist.defineData("Index","Position_Code","Count");
 rc = positionsDist.defineDone();
 lr = 0;
 Index = 0;
 do until(lr);
    set bizarro.positions end=lr;
    do i = 1 to Count;
       Index + 1;
       rc = positionsDist.add();
    end;
 end;
 rc = positionsDist.output(dataset:"positions");
 
 declare hash fname(dataset: "first_names");
 rc = fname.defineKey("First_Name");
 rc = fname.defineData("First_Name");
 rc = fname.defineDone();
 declare hiter first_iter("fname");
 
 declare hash lname(dataset: "last_names");
 rc = lname.defineKey("Last_Name");
 rc = lname.defineData("Last_Name");
 rc = lname.defineDone();
 declare hiter last_iter("lname");
 
 declare hash players();
 rc = players.defineKey("Arbtrary","First_Name","Last_Name");
 rc = players.defineData("Player_ID","Team_SK","First_Name","Last_Name"
                        ,"Position_Code","Bats","Throws");
 rc = players.defineDone();
 
 Arbtrary = 0;
 do frc = first_iter.first() by 0 while(frc = 0);
    do lrc = last_iter.first() by 0 while(lrc = 0);
       Arbitrary + 1;
       positionsDist.find(Key:ceil(uniform(&seed2)*&nPlayersPerTeam));
       Player_ID + ceil(uniform(&seed3)*9);
       random = uniform(&seed10);
       if random le .1 then Bats = "S";
       else if random le .35 then Bats = "L";
       else Bats = "R";
       if uniform(&seed11) le .3 then Throws = "L";
       else Throws = "R";
       players.add();
       lrc = last_iter.next();
    end;
    frc = first_iter.next();
 end;
 players.output(dataset:"bizarro.player_candidates");
 
run;