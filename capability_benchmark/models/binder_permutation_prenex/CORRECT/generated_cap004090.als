sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
trans in State -> some Event -> State
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004090 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchA and no CapBenchB) and some CapBenchB))) }
pred cap004090c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap004090 { cap004090 iff cap004090c }
check CapBenchEquivalent_cap004090 for 4
