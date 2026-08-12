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

pred cap005276 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchR and no CapBenchA) or some capBenchR)) and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005276c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some capBenchR and no CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap005276 { cap005276 iff cap005276c }
check CapBenchEquivalent_cap005276 for 4
