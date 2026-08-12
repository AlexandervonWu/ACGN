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

pred cap004185 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap004185c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap004185 { cap004185 iff cap004185c }
check CapBenchEquivalent_cap004185 for 4
