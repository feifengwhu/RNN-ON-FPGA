.PS
cct_init
log_init
elen = 0.75

define mult   { circle "\Huge $\times$" radius 0.15}
define sum    { circle "\LARGE $+$" radius 0.15}
define diff    { circle "\LARGE $-$" radius 0.15}
#define multE  { circle radius 0.2; circle fill 0 radius 0.13 at last circle}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:Q;E:CK,,:D;)}

#ElemM: circle radius 0.2; circle fill 0 radius 0.07 at ElemM
#Nlinz: box ht boxht wid boxht "$\tanh(\mathbf{x})$" at GateZ.e+(1.25*elen,0)

# The Gate
Gate: box "Gate $\mathbf{*}^{(t)}$"
Pmux: Mux(2, Pert) at Gate.w-(elen,0.075)
line from Gate.w to Pmux.Out "$\mathbf{w}_*^{(t)}$" above
SumP: sum at Pmux.In1-(0.5*elen,0)
line from SumP.e to Pmux.In1

# The weight RAM
Wram: box wid 1 ht 1 at Pmux.In0-(2.25*elen,0) "Weight" "RAM"
ArrowStart: SumP.n+(-0.75,1.5*elen)
line from ArrowStart to (Wram.n.x+0.3,ArrowStart.y) "writeUpdate" below ljust; arrow down to (Wram.n.x+0.3,Wram.n.y)
line from Wram.e to Pmux.In0
MidPointL0: Wram.e+(0.5*elen,0)
MidPointS: (MidPointL0.x, SumP.w.y);

"addrW" at Wram.n below;
"addrR" at Wram.s above;
"In" at Wram.w ljust;
"Out" at Wram.e rjust;
"En" at Wram.n+(0.35,-0.1);

Pram: box wid 1 ht 1 at Wram-(0,5*elen) "Sign" "RAM"
SPmux: Mux(2) at Pram.e+(elen,1.25*elen)
"$\beta$" at SPmux.In0-(0.1,0) rjust
"$-\beta$" at SPmux.In1-(0.1,0) rjust
"pertWeighs" at Pmux.Sel-(0,0.05) ljust
line from Pram.e to (SPmux.Sel.x, Pram.e.y) then up to SPmux.Sel
line from SPmux.Out to (Pmux.Sel.x,SPmux.Out.y) then up 1.75*elen; dot;
{
  left; line 0.95*elen ; 
  Signchg: box wid 0.8 ht 0.25 "Sign Change";
}
line up 0.5*elen; arrow left from Here to (SumP.s.x, Here.y) then up to SumP.s
line from MidPointL0 down to (MidPointL0.x, SumP.w.y); dot;
{
  down; arrow to Signchg.n;
}
arrow right to SumP.w
RowFF: FF at Signchg.w-(2*elen,0.162)
PrevYSum: sum at Wram.w-(2*elen,0)
arrow from Signchg.w to RowFF.E1
arrow from RowFF.W1 right to (PrevYSum.s.x,RowFF.W1.y) then up to PrevYSum.s
DiffY: diff at PrevYSum+(0,elen)
arrow from DiffY.s to PrevYSum.n
arrow from DiffY.w-(0.3,0) to DiffY.w "$J^{(t)}$" above
arrow from DiffY.e+(0.3,0) to DiffY.e "$J^{(t)}_p$" above ljust

Shift: box wid 0.75 ht 0.45 at PrevYSum.e+(0.85*elen,0) "Shift Right" "by $(\beta-\alpha)$"
arrow from PrevYSum.e to Shift.w
arrow from Shift.e to Wram.w
UpdateMux: Mux(2) at PrevYSum-(0,3*elen)
line left 1.5*elen from UpdateMux.In0 "colAddressRead" above
line down 0.25*elen from UpdateMux.Sel "weightUpdate" ljust
line from UpdateMux.Out to (Wram.x,UpdateMux.Out.y); dot;
{
    up; arrow to Wram.s;
}
arrow to Pram.n;

PRNG: box wid 1.2 ht 0.6 at Pram-(2.5*elen,0) "Pseudo Random" "Number Generator"
arrow from PRNG.e to Pram.w
line from PRNG.n+(-elen,0.55*elen) right to (PRNG.n.x,PRNG.n.y+0.55*elen) "genRandNum" above rjust; dot;
{
  down; arrow to PRNG.n
}
arrow to (Pram.n.x+0.3,PRNG.n.y+0.55*elen) then down to (Pram.n.x+0.3, Pram.n.y)

FSM: box at Gate+(0,2.5*elen) "State" "Machine"
PrevCFF: FF at SumP+(0.2,2.15*elen)
line from FSM.w left 1*elen; dot;
{
  down; line down to (Here.x,PrevCFF.E1.y) then to PrevCFF.E1;
  arrow from PrevCFF.W1 to (Wram.n.x,PrevCFF.W1.y) then to Wram.n
  
}
line left 8*elen;
Corner: Here;
line down 8.5*elen;
line from Here to (Pram.s.x,Here.y); arrow up to Pram.s 
line from UpdateMux.In1 to (Corner.x,UpdateMux.In1.y); dot;

"addrW" at Pram.n below;
"addrR t" at Pram.s above;
"In" at Pram.w ljust;
"Out" at Pram.e rjust;
"En" at Pram.n+(0.35,-0.1);

.PE