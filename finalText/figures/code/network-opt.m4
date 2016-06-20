.PS
cct_init
log_init
elen = 0.75

define mult   { circle "\Huge $\times$" radius 0.15}
define sum    { circle "\LARGE $+$" radius 0.15}
#define multE  { circle radius 0.2; circle fill 0 radius 0.13 at last circle}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:D;E:CK,,:Q;)}

#ElemM: circle radius 0.2; circle fill 0 radius 0.07 at ElemM
#Nlinz: box ht boxht wid boxht "$\tanh(\mathbf{x})$" at GateZ.e+(1.25*elen,0)

# The Gates
GateZ: box "Gate $\mathbf{z}^{(t)}$"
GateI: box "Gate $\mathbf{i}^{(t)}$" at GateZ.s+(0,-0.5*elen)
GateF: box "Gate $\mathbf{f}^{(t)}$" at GateI.s+(0,-0.5*elen)
GateO: box "Gate $\mathbf{o}^{(t)}$" at GateF.s+(0,-0.5*elen)

# The Muxes
MidPointBetweenMux: (GateZ.e.x+1.55*elen, (GateZ.n.y+GateO.s.y)*0.5)
MuxUpPoint:   (MidPointBetweenMux.x, GateI.n.y)
MuxDownPoint: (MidPointBetweenMux.x, GateO.n.y)
InMuxUp:   Mux(3, Sel) at MuxUpPoint
InMuxDown: Mux(3, Sel) at MuxDownPoint-(0,0.025)
"N.A." at InMuxUp.In1-(0.35*elen,0)
"$\mathbf{c}$(t)" at InMuxUp.In2-(0.35*elen,0)

# The connections between Gates and Muxes
line from GateZ.e right 0.5*elen; line from Here to (Here.x,InMuxUp.In0.y) then to InMuxUp.In0
line from GateI.e right 0.5*elen; line from Here to (Here.x,InMuxDown.In0.y) then to InMuxDown.In0
line from GateF.e right 0.25*elen; line from Here to (Here.x,InMuxDown.In1.y) then to InMuxDown.In1
line from GateO.e right 0.25*elen; line from Here to (Here.x,InMuxDown.In2.y) then to InMuxDown.In2

# The non-linearities
Tanh: box ht boxht wid boxht "$\tanh(\mathbf{x})$" at InMuxUp.Out+(0.75*elen,0)
Sigm: box ht boxht wid boxht "$\sigma(\mathbf{x})$" at InMuxDown.Out+(0.75*elen,0)
arrow from InMuxUp.Out to Tanh.w
arrow from InMuxDown.Out to Sigm.w

# The mux that chooses input to elementwise multiplication
EMmux: Mux(2, OpSel) at Tanh.e+(elen,-0.3)
line from Tanh.e to EMmux.In0
line from EMmux.In1 left 0.5*elen "$\mathbf{c}$(t-1)" below   ; dot

# The final elementwise multiplication
ElemM: circle radius 0.15 at (EMmux.Out.x+0.35*elen,MidPointBetweenMux.y) ; circle fill 0 radius 0.04 at ElemM
arrow from EMmux.Out right to (ElemM.n.x,EMmux.Out.y) then down to ElemM.n
arrow from Sigm.e right to (ElemM.s.x, Sigm.e.y) then up to ElemM.s

# The output flip-flops.
PrevYFF: FF at ElemM.e+(elen,0.716*elen)
ZreadFF: FF at PrevYFF.s-(0,0.5*elen)
FreadFF: FF at ZreadFF.s-(0,0.5*elen)
LineInts: ((ElemM.e.x+ZreadFF.W1.x)*0.5,ElemM.e.y);
line from ElemM.e to LineInts; dot
line from LineInts up   to (LineInts.x,ZreadFF.W1.y) then to ZreadFF.W1
line from LineInts up   to (LineInts.x,PrevYFF.W1.y) then to PrevYFF.W1
line from LineInts down to (LineInts.x,FreadFF.W1.y) then to FreadFF.W1

# The state calculator
Csum: sum at (ZreadFF.W1.x+1.25*elen,(ZreadFF.W1.y+FreadFF.W1.y)*0.5)
CFF: FF at Csum+(elen,-0.162)
arrow from ZreadFF.E1 right to (Csum.n.x,ZreadFF.E1.y) then to Csum.n
arrow from FreadFF.E1 right to (Csum.s.x,FreadFF.E1.y) then to Csum.s
line from Csum.e to CFF.W1 "$\mathbf{c}$(t)" above
line from CFF.E1 right "$\mathbf{c}$(t-1)" above; dot
line from PrevYFF.E1 right "$\mathbf{y}$(t-1)" above; dot
.PE