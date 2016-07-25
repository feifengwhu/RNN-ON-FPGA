.PS
cct_init
log_init
elen = 0.75

# The multiplier block
define mult { circle "\Huge $\times$" radius 0.2}
define sum  { circle "\Huge $+$" radius 0.2}
define FF   {FlipFlopX(wid 6.5*L_unit ht 13*L_unit,,:D;E:CK,,:Q;)}

Origin: Here
  # The d
  Mux_sum:  Mux(2,Prod,,8*L_unit, 21*L_unit)
  line  from Mux_sum.In0-(elen,0) to Mux_sum.In0 "$p_2$" above;
  
  # The FlipFlop that keeps the current state
  FlipFlop_state: FF at Mux_sum.sw-(elen,1.5*elen)

  # The summing block
  State_sum: sum at FlipFlop_state.W1-(elen,0)
  arrow from State_sum.w-(elen,0) to State_sum.w  "1" above;
  line from State_sum.e to FlipFlop_state.W1
  line from FlipFlop_state.E1 right 0.3*elen
  {
    up; line elen; arrow from Here to (State_sum.n.x, Here.y) then down to State_sum.n
  }
  line from Here to (Mux_sum.Sel.x, Here.y)
  
  # The down mux that selects the input to the output sum block
  Mux_prod: Mux(2,Sum,BN, 8*L_unit, 21*L_unit) at Mux_sum.s+(0,1.4*FlipFlop_state.E1.y)
  line  from Mux_prod.In0-(elen,0) to Mux_prod.In0 "$p_1$" above; 
  line  from Mux_prod.In1-(elen,0) to Mux_prod.In1 "$p_0$" above; 
  
  
  line from Mux_prod.Sel to Mux_sum.Sel
  
  # The multiplier block
  Mult: mult at Mux_sum.Out+(elen,0)
  arrow from Mux_sum.Out to Mult.w
  arrow from Mult.n+(0,elen) to Mult.n "$x$" ljust;
  
  # The shift block
  Shift: box at Mult-(0,1.8*elen) "$>>>$ QM"
  arrow from Mult.s to Shift.n
  
  # The output sum block
  Out_sum: sum at (Mult, Mux_prod.Out)
  arrow from Mux_prod.Out to Out_sum.w
  arrow from Shift.s to Out_sum.n
  
  # The output flip-flop
  FlipFlop_out: FF at (Out_sum.x+1.5*elen, Out_sum.y-0.164)
  line from Out_sum.e to FlipFlop_out.W1
  line from FlipFlop_out.E1 right 0.5*elen
  { right; line 0.5*elen "$f(x)$" above}
  line up to (Here.x, Mult.y+2*elen); line right to (Mux_sum.In1.x-1.5*elen,Here.y); line down to (Here.x, Mux_sum.In1.y) then right to Mux_sum.In1
.PE

