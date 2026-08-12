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

pred cap005334 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005334c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005334 { cap005334 iff cap005334c }
check CapBenchEquivalent_cap005334 for 4
