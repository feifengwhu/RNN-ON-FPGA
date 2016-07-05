.PS
cct_init
log_init
elen = 0.75

define mult { circle "\Huge $\times$" radius 0.2}
define sum  { circle "\Huge $+$" radius 0.2}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:D;E:CK,,:Q;)}

Origin: Here

# The memory positions
Mem0: box ht 0.5*boxht wid 1.6*boxwid fill "$w(0, \;\text{colSel})$"
Mem1: box ht 0.5*boxht wid 1.6*boxwid fill at Mem0-(0,0.3*boxwid) "$w(1, \;\text{colSel})$"
Mem2: box ht 0.5*boxht wid 1.6*boxwid fill at Mem1-(0,0.3*boxwid) "$w(2, \;\text{colSel})$"
Mem3: box ht 0.5*boxht wid 1.6*boxwid fill at Mem2-(0,0.3*boxwid) "$w(3, \;\text{colSel})$"
Mem4: box ht 0.5*boxht wid 1.6*boxwid fill 0.8 at Mem3-(0,0.3*boxwid) "$w(K_G, \;\text{colSel})$"
Mem5: box ht 0.5*boxht wid 1.6*boxwid fill 0.8 at Mem4-(0,0.3*boxwid) "$w(K_G+1, \;\text{colSel})$"
Mem6: box ht 0.5*boxht wid 1.6*boxwid fill 0.8 at Mem5-(0,0.3*boxwid) "$w(K_G+2, \;\text{colSel})$"
Mem7: box ht 0.5*boxht wid 1.6*boxwid fill 0.8 at Mem6-(0,0.3*boxwid) "$w(K_G+3, \;\text{colSel})$"
BoxesTop: Mem1.sw-(0.25*elen,0)
BoxesDwn: Mem5.sw-(0.25*elen,0)

arrow from BoxesTop to Mem0.nw-(0.25*elen,0)
arrow from BoxesTop to Mem3.sw-(0.25*elen,0)
arrow from BoxesDwn to Mem4.nw-(0.25*elen,0)
arrow from BoxesDwn to Mem7.sw-(0.25*elen,0)
"Multiplier 1" at BoxesTop-(0.75*elen,0)
"Multiplier 2" at BoxesDwn-(0.75*elen,0)
"Column = colSel" at Mem7.s-(0,0.3*elen)

arrow from Mem0.e right 0.75*elen "rowMux = 0" ljust above
arrow from Mem4.e right 0.75*elen "rowMux = 0" ljust above
arrow from Mem2.e right 0.75*elen "rowMux = 2" ljust above
arrow from Mem6.e right 0.75*elen "rowMux = 2" ljust above
.PE