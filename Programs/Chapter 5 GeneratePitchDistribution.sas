/* "Chapter 5 GeneratePitchDistribution.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

data bizarro.pitch_distribution;
 Pitch_Distribution_SK = _n_;
 input Result $16. AB_Done Is_An_AB Is_An_Out Is_A_Hit Is_An_OnBase Bases Runners_Advance_Factor From To;
 label Pitch_Distribution_SK = "Pitch Distribution Surrogate Key"
       Result = "Result of the Pitch"
       AB_Done = "Final Pitch of the AB"
       Is_An_AB = "Counts as an AB"
       Is_An_Out = "Is an Out"
       Is_A_Hit = "Is a Hit"
       Is_An_OnBase = "Counts as an On Base"
       Bases = "Number of Bases for the Hit"
       Runners_Advance_Factor = "Proabability of an Extra Base"
       From = "Lower Range of Distribution"
       to = "Upper Range of Distribution"
 ;
 datalines;
Ball             0 . . . . . .    1  33
Called Strike    0 . . . . . .   34  48
Double           1 1 0 1 1 2 .7  49  51
Error            1 1 0 0 0 1 .4  52  52
Foul             0 . . . . . .   53  68
Hit By Pitch     1 0 0 0 1 1 0   69  69
Home Run         1 1 0 1 1 4 0   70  71
Out              1 1 1 0 0 0 0   72  83
Single           1 1 0 1 1 1 .5  84  88
Swinging Strike  0 . . . . . .   89  99
Triple           1 1 0 1 1 3 0  100 100
run;
 
data bizarro.hit_distance;
 Hit_Distance_SK = _n_;
 input Pitch_Distribution_FK MinDistance MaxDistance;
 label Hit_Distance_SK = "Hit Distance Surrogate Key"
       Pitch_Distribution_FK = "Pitch Distribution Foreign Key"
       MinDistance = "Hit Distance Minimum"
       MaxDistance = "Hit Distance Maximum"
 ;
 datalines;
 3 200 300
 4  50 300
 7 390 480
 8   3 385
 9  10 100
11 310 390
run;