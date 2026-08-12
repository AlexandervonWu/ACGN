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

pred cap002232 { not (all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or no CapBenchB)))) }
pred cap002232c { some x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap002232 { cap002232 iff cap002232c }
check CapBenchEquivalent_cap002232 for 4
