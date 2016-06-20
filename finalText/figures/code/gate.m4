.PS
cct_init
log_init
elen = 0.75

define mult   { circle "\Huge $\times$" radius 0.15}
define sum    { circle "\LARGE $+$" radius 0.15}
#define multE  { circle radius 0.2; circle fill 0 radius 0.13 at last circle}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:D;E:CK,,:Q;)}

#ElemM: circle radius 0.2; circle fill 0 radius 0.07 at ElemM

# The Dot Prods
DotProdX: box "Dot Prod." "$\mathbf{W}_* \cdot \mathbf{x}^{(t)}$"
DotProdY: box at DotProdX+(0,-2*elen) "Dot Prod." "$\mathbf{R}_* \cdot \mathbf{x}^{(t)}$"

# The RAMs
RamX: box at DotProdX-(2.5*elen,0) "$\mathbf{W}_*$" "RAM"
RamY: box at DotProdY-(2.5*elen,0) "$\mathbf{R}_*$" "RAM"
arrow from RamX.ne-(0,0.15) to DotProdX.nw-(0,0.15) "$W_* (:,\text{colSel})$" above
arrow from DotProdX.sw+(0,0.15) to RamX.se+(0,0.15) "colSel" below
arrow from RamY.ne-(0,0.15) to DotProdY.nw-(0,0.15) "$R_* (:,\text{colSel})$" above
arrow from DotProdY.sw+(0,0.15) to RamY.se+(0,0.15) "colSel" below

# The X sum
SumX: sum at DotProdX.e+(elen,0)
arrow from DotProdX.e to SumX.w
arrow from SumX+(0,elen) to SumX.n "$\mathbf{b}_*$" ljust
FFX: FF at SumX+(elen,-0.1625)
line from SumX.e to FFX.W1

# The Y sum
OutSum: (FFX.E1.x+0.5*elen,(RamX.s.y+RamY.n.y)*0.5)
SumY: sum at OutSum
arrow from FFX.E1 right to (SumY.n.x,FFX.E1.y) then to SumY.n
arrow from DotProdY.e right to (SumY.s.x,DotProdY.e.y) then to SumY.s

# THe out FF
FFY: FF at SumY.e+(1.25*elen,-0.1625)
line from SumY.e to FFY.W1
arrow from FFY.E1 right "Gate Output" above ljust

# The control signals
"X ready" at FFX.W2-(0.5*elen,0)
"Y ready" at FFY.W2-(0.5*elen,0)
.PE
