data bizarro.pitch_distribution;
 input Result $16. AB_Done Is_An_AB Is_An_Out Is_A_Hit Bases Runners_Advance_Factor From To;
 datalines;
Ball             0 . . . . .    1  33
Called Strike    0 . . . . .   34  48
Double           1 1 0 1 2 .7  49  51
Error            1 1 0 0 1 .4  52  52
Foul             0 . . . . .   53  68
Hit By Pitch     1 0 0 0 1 0   69  69
Home Run         1 1 0 1 4 0   70  71
Out              1 1 1 0 0 0   72  83
Single           1 1 0 1 1 .5  84  88
Swinging Strike  0 . . . . .   89  99
Triple           1 1 0 1 3 0  100 100
run;
