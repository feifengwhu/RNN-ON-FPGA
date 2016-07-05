.PS
cct_init
log_init
elen = 0.75

define mult   { circle "\Huge $\times$" radius 0.15}
define sum    { circle "\LARGE $+$" radius 0.15}
#define multE  { circle radius 0.2; circle fill 0 radius 0.13 at last circle}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:D;E:CK,,:Q;)}

#ElemM: circle radius 0.2; circle fill 0 radius 0.07 at ElemM

# The Gates
GateZ: box "Gate $\mathbf{z}^{(t)}$"
GateI: box "Gate $\mathbf{i}^{(t)}$" at GateZ.s+(0,-0.75*elen)
GateF: box "Gate $\mathbf{f}^{(t)}$" at GateI.s+(0,-0.75*elen)
GateO: box "Gate $\mathbf{o}^{(t)}$" at GateF.s+(0,-0.75*elen)

# The non-linearites
Nlinz: box ht boxht wid boxht "$\tanh(\mathbf{x})$" at GateZ.e+(1.25*elen,0)
Nlini: box ht boxht wid boxht "$\sigma(\mathbf{x})$" at GateI.e+(1.25*elen,0)
Nlinf: box ht boxht wid boxht "$\sigma(\mathbf{x})$" at GateF.e+(1.25*elen,0)
Nlino: box ht boxht wid boxht "$\sigma(\mathbf{x})$" at GateO.e+(1.25*elen,0)
arrow from GateZ.e to Nlinz.w
arrow from GateI.e to Nlini.w
arrow from GateF.e to Nlinf.w
arrow from GateO.e to Nlino.w

ElemM1: circle radius 0.15 at (Nlinz.e.x+elen,(Nlinz.s.y + Nlini.n.y)*0.5); circle fill 0 radius 0.04 at ElemM1
ElemM2: circle radius 0.15 at (Nlinz.e.x+elen,Nlinf.e.y); circle fill 0 radius 0.04 at ElemM2
Sum: sum at (ElemM1.e.x+elen, (ElemM1.s.y+ElemM2.n.y)*0.5)
SumFF: FF at Sum-(0,elen+0.023)
ElemO: circle radius 0.15 at (Sum.x+3*elen,ElemM2.e.y); circle fill 0 radius 0.04 at ElemO
NlinO: box ht boxht wid boxht "$\tanh(\mathbf{x})$" at ElemO.w-(0.9*elen,0)

line from Nlinz.e; line from Here to (ElemM1.n.x,Here.y); arrow from Here to ElemM1.n
line from Nlini.e; line from Here to (ElemM1.s.x,Here.y); arrow from Here to ElemM1.s
arrow from Nlinf.e to ElemM2.w
arrow from ElemM2.n up to (ElemM2.n.x,Sum.w.y) then right to Sum.w
arrow from ElemM1.e right to (Sum.n.x,ElemM1.e.y) then down to Sum.n
line from Sum.e right
{
  down; line to (Here.x, ElemM2.e.y) then to SumFF.E1 "$\mathbf{c}^{(t)}$" above;
  arrow from SumFF.W1 to ElemM2.e "$\mathbf{c}^{(t-1)}$" above
  }
arrow from SumFF.E1 to NlinO.w
arrow from NlinO.e to ElemO.w
arrow from Nlino.e right to (ElemO.s.x, Nlino.e.y) then to ElemO.s
arrow from ElemO.e right "$\mathbf{y}^{(t)}$" above
.PE
