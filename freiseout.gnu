reset
set xrange[0:0]
set xlabel ""
set ylabel "Abs "
set mxtics 2
set mytics 2
set zero 0.0
set title "freiseout                Tue Aug  4 16:22:24 2015" offset 0, 2
set nolog y
set format y "%g"
set term x11
set size ratio .5
set key below
set grid xtics ytics
 set title
plot\
'freiseout.out' using ($1):($2) axes x1y1 title "pow n3 :  " w l lt 1 lw 2, \
'freiseout.out' using ($1):($3) axes x1y1 title "ad00 n3 :  " w l lt 2 lw 2, \
'freiseout.out' using ($1):($4) axes x1y1 title "ad10 n3 :  " w l lt 3 lw 2, \
'freiseout.out' using ($1):($5) axes x1y1 title "ad01 n3 :  " w l lt 4 lw 2, \
'freiseout.out' using ($1):($6) axes x1y1 title "ad20 n3 :  " w l lt 5 lw 2, \
'freiseout.out' using ($1):($7) axes x1y1 title "ad11 n3 :  " w l lt 6 lw 2, \
'freiseout.out' using ($1):($8) axes x1y1 title "ad02 n3 :  " w l lt 7 lw 2
