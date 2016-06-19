.PS
cct_init
log_init
elen = 0.75

define mult { circle "\Huge $\times$" radius 0.2}
define sum  { circle "\Huge $+$" radius 0.2}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:D;E:CK,,:Q;)}

Origin: Here

InMux: Mux(4,InSel,,8*L_unit, 24*L_unit)
Mult:  mult at InMux.Out+(1*elen,0)
Sum:   sum  at Mult+(1.5*elen,0)
AccFF: FF   at Sum.e+(0.75*elen,-0.1625)
OutDmux: Demux(4,OutSel,,8*L_unit, 24*L_unit) at AccFF+(2*elen,0.091)

"rowMux" at InMux.Sel-(0,0.2)
"rowMux" at OutDmux.Sel-(0,0.2)

arrow from InMux.Out to Mult.w
arrow from Mult.e to Sum.w
InArr : arrow from Mult.n+(0,0.75*elen) to Mult.n
"$x(\text{colSel})$" at InArr.n+(0,0.1)
line  from Sum.e to AccFF.W1
line  from AccFF.E1 right 0.5*elen
{
  up; line 0.75*elen; arrow from Here to (Sum.n.x, Here.y) then to Sum.n
  }
dot; arrow from Here to OutDmux.In

# The memory positions
Mem0: box ht 0.5*boxht wid 2.4*boxwid at InMux.In0-(1.5*elen,0) fill "$w(i\cdot K_G + 0, \;\text{colSel})$"
Mem1: box ht 0.5*boxht wid 2.4*boxwid at InMux.In1-(1.5*elen,0) fill "$w(i\cdot K_G + 1, \;\text{colSel})$"
Mem2: box ht 0.5*boxht wid 2.4*boxwid at InMux.In2-(1.5*elen,0) fill "$\cdots$"
Mem3: box ht 0.5*boxht wid 2.4*boxwid at InMux.In3-(1.5*elen,0) fill "$w(i\cdot K_G + \left[K_G-1\right], \;\text{colSel})$"
line from Mem0.e to InMux.In0
line from Mem1.e to InMux.In1
line from Mem2.e to InMux.In2
line from Mem3.e to InMux.In3
Out0: "$y(i\cdot K_G + 0)$" at OutDmux.Out0+(1.2*elen,0)
Out1: "$y(i\cdot K_G + 1)$" at OutDmux.Out1+(1.2*elen,0) 
Out2: "$\cdots$" at OutDmux.Out2+(1.2*elen,0) 
Out3: "$y(i\cdot K_G + \left[K_G-1\right])$" at OutDmux.Out3+(1.2*elen,0) 
line from OutDmux.Out0 to Out0.w-(elen,0) 
line from OutDmux.Out1 to Out1.w-(elen,0) 
line from OutDmux.Out2 to Out2.w-(elen,0) 
line from OutDmux.Out3 to Out3.w-(elen,0) 



.PE