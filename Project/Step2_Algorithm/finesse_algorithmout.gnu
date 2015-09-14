reset
set xrange[0:180]
set xlabel "phi [deg] (etm)"
set ylabel "Abs "
set mxtics 2
set mytics 2
set zero 0.0
set title "finesse_algorithmout                Tue Sep  8 11:53:57 2015" offset 0, 2
set nolog y
set format y "%g"
set term x11 
set size ratio .5 
set key below 
set grid xtics ytics 
plot\
'finesse_algorithmout.out' using ($1):($2) axes x1y1 title " n3 :  " w l lt 1 lw 2
