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

pred cap005446 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or some capBenchS) and some CapBenchB))) }
pred cap005446c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some capBenchS) and some CapBenchB)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005446 { cap005446 iff cap005446c }
check CapBenchEquivalent_cap005446 for 4
