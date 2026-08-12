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

pred cap005303 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005303c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap005303 { cap005303 iff cap005303c }
check CapBenchEquivalent_cap005303 for 4
