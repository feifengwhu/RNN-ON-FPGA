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
GateI: box "Gate $\mathbf{i}^{(t)}$" at GateZ.s+(0,-0.75*elen)
GateF: box "Gate $\mathbf{f}^{(t)}$" at GateI.s+(0,-0.75*elen)
GateO: box "Gate $\mathbf{o}^{(t)}$" at GateF.s+(0,-0.75*elen)

# The Muxes
MidPointBetweenMux: (GateZ.e.x+1.5*elen, (GateZ.n.y+GateO.s.y)*0.5)
MuxUpPoint:   (MidPointBetweenMux.x, GateI.n.y)
MuxDownPoint: (MidPointBetweenMux.x, GateO.n.y)
InMuxUp:   Mux(3, Sel) at MuxUpPoint+(0,0.188)
InMuxDown: Mux(3, Sel) at MuxDownPoint-(0,0.025)

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

# The final elementwise multiplication
ElemM: circle radius 0.15 at (EMmux.Out.x+0.5*elen,MidPointBetweenMux.y) ; circle fill 0 radius 0.04 at ElemM
arrow from EMmux.Out right to (ElemM.n.x,EMmux.Out.y) then down to ElemM.n
arrow from Sigm.e right to (ElemM.s.x, Sigm.e.y) then up to ElemM.s

.PE