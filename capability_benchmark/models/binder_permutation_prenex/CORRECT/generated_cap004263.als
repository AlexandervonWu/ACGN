sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s: State | some s.trans
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

pred cap004263 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap004263c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap004263 { cap004263 iff cap004263c }
check CapBenchEquivalent_cap004263 for 4
