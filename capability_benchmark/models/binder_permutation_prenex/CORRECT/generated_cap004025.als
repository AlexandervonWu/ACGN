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

pred cap004025 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or no CapBenchB) or some CapBenchA))) }
pred cap004025c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap004025 { cap004025 iff cap004025c }
check CapBenchEquivalent_cap004025 for 4
