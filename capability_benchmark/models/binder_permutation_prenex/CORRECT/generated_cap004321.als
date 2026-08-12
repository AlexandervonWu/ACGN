sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s : State | some s.trans
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

pred cap004321 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchS))) }
pred cap004321c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap004321 { cap004321 iff cap004321c }
check CapBenchEquivalent_cap004321 for 4
