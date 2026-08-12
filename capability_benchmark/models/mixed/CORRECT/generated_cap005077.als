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

pred cap005077 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or some CapBenchB) or some CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap005077c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) or (not (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005077 { cap005077 iff cap005077c }
check CapBenchEquivalent_cap005077 for 4
